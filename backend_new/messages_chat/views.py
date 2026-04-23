from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Message
from .serializers import MessageSerializer


# GET /api/messages/    → list all messages for the logged-in user
# POST /api/messages/   → send a new message
class MessageListCreateView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    # Only show messages where the logged-in user is sender OR receiver
    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(
            expediteur=user
        ).union(
            Message.objects.filter(destinataire=user)
        ).order_by('-date_envoi')

    # Automatically set expediteur to the logged-in user when sending
    def perform_create(self, serializer):
        serializer.save(expediteur=self.request.user)


# GET /api/messages/<uuid>/    → get one message
# DELETE /api/messages/<uuid>/ → delete one message
class MessageDetailView(generics.RetrieveDestroyAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(expediteur=user) | Message.objects.filter(destinataire=user)
