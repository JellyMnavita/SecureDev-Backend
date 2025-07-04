# contact/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.mail import send_mail


class ContactAPIView(APIView):
    def post(self, request):
        data = request.data
        try:
            message = f"""
Nom: {data.get('firstName')} {data.get('lastName')}
Email: {data.get('email')}
Téléphone: {data.get('phone')}
Service: {data.get('subject')}
Budget: {data.get('budget')}
Délai: {data.get('timeline')}

Message:
{data.get('message')}
            """

            send_mail(
                subject=f"[Formulaire Contact] {data.get('subject')}",
                message=message,
                from_email="jej042817@gmail.com",
                recipient_list=["jej042817@gmail.com"],
                fail_silently=False,
            )

            return Response(
                {"message": "Votre message a bien été envoyé."},
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            return Response(
                {"message": f"Erreur lors de l'envoi: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
