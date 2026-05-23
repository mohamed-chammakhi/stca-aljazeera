from django.db.models import Q
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Message
from .serializers import MessageSerializer


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
