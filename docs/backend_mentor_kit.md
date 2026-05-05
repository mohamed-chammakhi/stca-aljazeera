# Backend Mentor Kit - Django/DRF

This file is a practical study guide for understanding and rebuilding the backend manually.
It is written for the final year report and oral defense: you should be able to explain each
piece in simple words and repeat the same pattern for any new backend module.

## 1. The Big Idea

Your backend is a Django REST Framework API.

The mobile app does not talk directly to the database. It sends HTTP requests to Django.
Django receives the request, checks authentication and permissions, validates the data,
reads or writes the database, then returns JSON.

The usual flow is:

```text
Flutter screen
  -> service class
  -> HTTP request
  -> Django URL
  -> Django view
  -> serializer validation
  -> model/database
  -> JSON response
```

In your project, this pattern appears in apps like:

- `users`
- `fournisseurs`
- `echantillons`
- `evaluations`
- `analyses`
- `sessions_degustation`
- `notifications`

## 2. The Repetitive Pattern

When you create a new backend feature, repeat these steps:

1. Create or update the model.
2. Create a serializer.
3. Create views.
4. Create URLs.
5. Add role permissions.
6. Run migrations.
7. Test with Swagger/Postman/Flutter.
8. Add tests.

This is the pattern you should memorize.

## 3. Mini Example: Supplier CRUD

Imagine we want to build a small supplier API manually.

### Step 1: Model

The model describes the database table.

```python
import uuid
from django.db import models


class Fournisseur(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=200)
    region = models.CharField(max_length=100, blank=True)
    telephone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nom
```

How to explain it:

> I created a Django model to represent suppliers in the database. Each supplier has a UUID
> primary key, contact fields, and an automatic creation date.

### Step 2: Serializer

The serializer converts model objects to JSON and validates incoming JSON.

```python
from rest_framework import serializers
from .models import Fournisseur


class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = [
            'id',
            'nom',
            'region',
            'telephone',
            'email',
            'date_creation',
        ]
        read_only_fields = ['id', 'date_creation']
```

How to explain it:

> The serializer is the bridge between Django objects and JSON. It decides which fields are
> exposed to the mobile app and which fields are read-only.

### Step 3: Views

The view contains the API behavior.

```python
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Fournisseur
from .serializers import FournisseurSerializer


class FournisseurListCreateView(generics.ListCreateAPIView):
    queryset = Fournisseur.objects.all().order_by('-date_creation')
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated]


class FournisseurDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated]
```

This gives you CRUD:

- `GET /api/fournisseurs/` lists suppliers.
- `POST /api/fournisseurs/` creates a supplier.
- `GET /api/fournisseurs/<id>/` gets one supplier.
- `PUT/PATCH /api/fournisseurs/<id>/` updates one supplier.
- `DELETE /api/fournisseurs/<id>/` deletes one supplier.

How to explain it:

> I used DRF generic views because they already implement common CRUD behavior. I only define
> the queryset, serializer, and permissions.

### Step 4: URLs

URLs connect API paths to views.

```python
from django.urls import path
from .views import FournisseurListCreateView, FournisseurDetailView

urlpatterns = [
    path('', FournisseurListCreateView.as_view(), name='fournisseur-list'),
    path('<uuid:pk>/', FournisseurDetailView.as_view(), name='fournisseur-detail'),
]
```

Then the project-level `urls.py` includes it:

```python
path('api/fournisseurs/', include('fournisseurs.urls')),
```

How to explain it:

> The app URL file defines local routes, and the main project URL file mounts them under
> `/api/fournisseurs/`.

## 4. When to Use APIView vs Generic Views vs ViewSet

Use `generics.ListCreateAPIView` when you need simple list/create CRUD.

Use `generics.RetrieveUpdateDestroyAPIView` when you need detail/update/delete CRUD.

Use `APIView` when the endpoint is a custom action, for example:

- submit an evaluation
- approve a session
- mark notifications as read
- export a PDF

Use `ModelViewSet` when one class should handle full CRUD plus custom actions.
Your `EchantillonViewSet` is an example.

## 5. Mini Example: Custom Action

Suppose a lab technician submits an analysis.

```python
from django.db import transaction
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated


class AnalyseSoumettreView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            analyse = AnalyseLabo.objects.select_related('echantillon').get(
                pk=pk,
                technicien=request.user,
            )
        except AnalyseLabo.DoesNotExist:
            return Response(
                {'detail': 'Analyse introuvable.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if analyse.statut == 'soumis':
            return Response(
                {'detail': 'Analyse deja soumise.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            analyse.statut = 'soumis'
            analyse.save()
            analyse.echantillon.statut_labo = 'soumis'
            analyse.echantillon.save()

        return Response(AnalyseLaboSerializer(analyse).data)
```

How to explain it:

> I used a custom APIView because submitting an analysis is not just a normal update. It changes
> the analysis status and also updates the related sample status. I used a transaction so both
> changes succeed together or fail together.

## 6. Permissions Pattern

Authentication answers:

> Who are you?

Permissions answer:

> Are you allowed to do this action?

Example:

```python
from rest_framework.permissions import BasePermission


class IsLaboratoire(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'laboratoire'
```

Use it like this:

```python
permission_classes = [IsAuthenticated, IsLaboratoire]
```

How to explain it:

> JWT confirms the identity of the user. Then role permissions check if that user has the correct
> role for the endpoint.

## 7. Your Project Workflow in Simple Words

### Sample creation

A collector creates an `Echantillon`.
Django attaches the logged-in collector automatically.
The sample starts with default statuses like `receptionne`, `non_evaluee`, and `en_attente`.

### Physical reception

When the sample physically arrives, it is marked as `recu_physiquement = true`.
After that, edits are tracked in `edit_history`.

### Tasting

A degustateur creates an `EvaluationOrganoleptique`.
When submitted, the evaluation becomes `soumis`.
The sample tasting status is updated.

### Laboratory

A lab technician creates an `AnalyseLabo`.
When submitted, the sample lab status becomes `soumis`.

### CEO decision

The direction can approve a sample for negotiation, refuse it, or confirm later workflow states.

### Notifications

Signals create notifications automatically when important events happen.

## 8. Practice Exercises

Do these exercises manually. Do not copy-paste first. Type them yourself.

### Exercise 1: Simple CRUD

Create a new app called `produits_test`.

Model:

- `id`
- `nom`
- `categorie`
- `prix`
- `date_creation`

Build:

- model
- serializer
- list/create view
- detail/update/delete view
- urls

Goal:

You should be able to create, list, update, and delete products.

### Exercise 2: Add Authentication

Protect all product endpoints with:

```python
permission_classes = [IsAuthenticated]
```

Goal:

Requests without JWT should fail.

### Exercise 3: Add Role Permission

Create a permission called `IsDirection`.

Only direction users can create, update, or delete products.
All authenticated users can list products.

Goal:

You understand the difference between read permissions and write permissions.

### Exercise 4: Add a Custom Action

Add a product status:

- `brouillon`
- `valide`
- `archive`

Create endpoint:

```text
POST /api/produits_test/<id>/valider/
```

This endpoint changes status from `brouillon` to `valide`.

Goal:

You understand why business actions are often custom endpoints.

### Exercise 5: Add History

Add a `history = models.JSONField(default=list, blank=True)`.

When price changes, store:

- old price
- new price
- user id
- date

Goal:

You understand audit logs.

## 9. Jury Questions and Strong Answers

Question:

> Why did you use Django REST Framework?

Answer:

> I used Django REST Framework because the mobile application needs a REST API. DRF gives
> serializers, authentication, permissions, pagination, and generic views, which helped me build
> structured API endpoints faster and more safely.

Question:

> What is the role of a serializer?

Answer:

> A serializer converts Django model objects into JSON for the mobile app. It also validates JSON
> sent by the client before saving it to the database.

Question:

> Why use UUID instead of integer IDs?

Answer:

> UUIDs are safer for distributed systems and mobile synchronization because they are globally
> unique and harder to guess than sequential integer IDs.

Question:

> How is authentication handled?

Answer:

> The backend uses JWT. After login, the server returns an access token and a refresh token.
> The Flutter app sends the access token in the Authorization header for protected requests.

Question:

> How do you protect endpoints by role?

Answer:

> I define permission classes that check `request.user.role`. For example, only a user with role
> `laboratoire` can access lab-specific actions, and only `direction` can access CEO actions.

Question:

> Why use transactions?

Answer:

> I use transactions when one business action updates multiple database records. For example,
> submitting an analysis updates the analysis and the related sample. A transaction ensures that
> both updates are saved together or both are rolled back.

Question:

> What is the difference between model, serializer, and view?

Answer:

> The model defines the database structure. The serializer defines how data is converted and
> validated. The view defines what happens when an API endpoint is called.

## 10. Fast Study Plan

Day 1:

- Understand model, serializer, view, URL.
- Rebuild simple CRUD manually.

Day 2:

- Add JWT authentication and role permissions.
- Practice explaining `IsAuthenticated` and custom permissions.

Day 3:

- Practice custom actions like submit, approve, refuse.
- Understand transactions.

Day 4:

- Study your real apps: `echantillons`, `evaluations`, `analyses`.
- Draw the workflow on paper.

Day 5:

- Prepare jury answers.
- Practice explaining one full request from Flutter to database and back.

## 11. The One Sentence to Remember

For every backend feature, ask:

```text
What data do I store? Who can access it? What JSON do I expose? What business action changes it?
```

If you can answer those four questions, you can design the backend feature.
