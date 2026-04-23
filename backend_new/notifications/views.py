from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Notification
from .serializers import NotificationSerializer


class NotificationListView(generics.ListAPIView):
    """GET /api/notifications/ — list the authenticated user's notifications.
    Optional query param: ?is_read=false to get only unread."""
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = Notification.objects.filter(destinataire=self.request.user)
        is_read = self.request.query_params.get('is_read')
        if is_read is not None:
            qs = qs.filter(is_read=is_read.lower() == 'true')
        return qs


class NotificationMarkReadView(generics.UpdateAPIView):
    """PATCH /api/notifications/<uuid>/ — mark one notification as read."""
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(destinataire=self.request.user)

    def partial_update(self, request, *args, **kwargs):
        notification = self.get_object()
        notification.is_read = True
        notification.save(update_fields=['is_read'])
        return Response(NotificationSerializer(notification).data)


class NotificationMarkAllReadView(APIView):
    """POST /api/notifications/read-all/ — mark all user notifications as read."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        updated = Notification.objects.filter(
            destinataire=request.user,
            is_read=False
        ).update(is_read=True)
        return Response({'updated': updated}, status=status.HTTP_200_OK)


class NotificationUnreadCountView(APIView):
    """GET /api/notifications/unread-count/ — returns count of unread notifications."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(destinataire=request.user, is_read=False).count()
        return Response({'count': count})
