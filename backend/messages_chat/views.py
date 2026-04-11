from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from django.db.models import Q
import django_filters

from .models import Message
from .serializers import MessageSerializer
from users.models import Role


class MessageFilter(django_filters.FilterSet):
    with_user = django_filters.UUIDFilter(method='filter_conversation')

    def filter_conversation(self, queryset, name, value):
        user = self.request.user
        return queryset.filter(
            Q(expediteur=user, destinataire_id=value) |
            Q(expediteur_id=value, destinataire=user)
        )

    class Meta:
        model  = Message
        fields = ['lu']


class MessageViewSet(viewsets.ModelViewSet):
    """
    Messages between collector ↔ direction.

    GET  /api/messages/?with_user=<uuid>  — conversation thread with a user.
    POST /api/messages/                   — send a message.
    PATCH /api/messages/<id>/mark_read/   — mark as read.
    """
    serializer_class   = MessageSerializer
    permission_classes = [IsAuthenticated]
    filterset_class    = MessageFilter

    def get_queryset(self):
        user = self.request.user
        # Each user only sees messages they sent or received.
        return Message.objects.filter(
            Q(expediteur=user) | Q(destinataire=user)
        ).select_related('expediteur', 'destinataire')

    def perform_create(self, serializer):
        serializer.save(expediteur=self.request.user)

    @action(detail=True, methods=['patch'])
    def mark_read(self, request, pk=None):
        """PATCH /api/messages/<id>/mark_read/ — mark message as read."""
        message = self.get_object()
        if message.destinataire != request.user:
            return Response({'detail': 'Not your message.'}, status=status.HTTP_403_FORBIDDEN)
        message.lu    = True
        message.lu_le = timezone.now()
        message.save()
        return Response(MessageSerializer(message, context={'request': request}).data)
