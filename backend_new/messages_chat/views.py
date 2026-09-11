from django.db.models import Q
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from users.models import User

from .models import Message
from .permissions import roles_contacts_autorises
from .serializers import ContactSerializer, MessageSerializer


class MessageListCreateView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return (
            Message.objects
            .filter(Q(expediteur=user) | Q(destinataire=user))
            .select_related('expediteur', 'destinataire')
            .order_by('-date_envoi')
        )

    def perform_create(self, serializer):
        serializer.save(expediteur=self.request.user)


class MessageDetailView(generics.RetrieveDestroyAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return (
            Message.objects
            .filter(Q(expediteur=user) | Q(destinataire=user))
            .select_related('expediteur', 'destinataire')
        )


class MessageMarkReadView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        try:
            message = Message.objects.get(pk=pk, destinataire=request.user)
        except Message.DoesNotExist:
            return Response(
                {'detail': 'Message introuvable.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if not message.lu:
            message.lu = True
            message.lu_le = timezone.now()
            message.save(update_fields=['lu', 'lu_le'])

        return Response(MessageSerializer(message, context={'request': request}).data)


class MessageContactsView(generics.ListAPIView):
    serializer_class = ContactSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        roles_autorises = roles_contacts_autorises(self.request.user)
        if not roles_autorises:
            return User.objects.none()
        return User.objects.filter(
            is_active=True,
            role__in=roles_autorises,
        ).order_by('nom', 'prenom')


class MessageUnreadCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        total = Message.objects.filter(destinataire=request.user, lu=False).count()
        return Response({'total': total})
