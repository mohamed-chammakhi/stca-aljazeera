from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import AnalyseLabo
from .serializers import AnalyseLaboSerializer


class AnalyseListCreateView(generics.ListCreateAPIView):
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return AnalyseLabo.objects.all().order_by('-date_analyse')

    def perform_create(self, serializer):
        serializer.save(technicien=self.request.user)


class AnalyseDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = AnalyseLabo.objects.all()
    serializer_class = AnalyseLaboSerializer
    permission_classes = [IsAuthenticated]
