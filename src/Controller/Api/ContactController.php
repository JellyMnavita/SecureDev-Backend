<?php

namespace App\Controller\Api;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Address;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Psr\Log\LoggerInterface;

class ContactController extends AbstractController
{
    #[Route('/api/contact', name: 'api_contact', methods: ['POST'])]
    public function sendEmail(
        Request $request,
        MailerInterface $mailer,
        ValidatorInterface $validator,
        LoggerInterface $logger
    ): JsonResponse {
        // Décodage et validation JSON
        $data = json_decode($request->getContent(), true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return $this->json([
                'success' => false,
                'message' => 'Invalid JSON payload'
            ], 400);
        }

        // Validation des données
        $constraints = new Assert\Collection([
            'firstName' => [
                new Assert\NotBlank(['message' => 'Le prénom est obligatoire']),
                new Assert\Length(['max' => 100])
            ],
            'lastName' => [
                new Assert\NotBlank(['message' => 'Le nom est obligatoire']),
                new Assert\Length(['max' => 100])
            ],
            'email' => [
                new Assert\NotBlank(['message' => 'L\'email est obligatoire']),
                new Assert\Email(['message' => 'Email invalide'])
            ],
            'phone' => new Assert\Optional([
                new Assert\Type(['type' => 'string', 'message' => 'Téléphone invalide']),
                new Assert\Length(['max' => 20])
            ]),
            'subject' => [
                new Assert\NotBlank(['message' => 'Le sujet est obligatoire']),
                new Assert\Length(['max' => 200])
            ],
            'budget' => new Assert\Optional([
                new Assert\Type(['type' => 'string']),
                new Assert\Length(['max' => 100])
            ]),
            'timeline' => new Assert\Optional([
                new Assert\Type(['type' => 'string']),
                new Assert\Length(['max' => 100])
            ]),
            'message' => [
                new Assert\NotBlank(['message' => 'Le message est obligatoire']),
                new Assert\Length(['max' => 2000])
            ]
        ]);

        $errors = $validator->validate($data, $constraints);

        if (count($errors) > 0) {
            $errorMessages = [];
            foreach ($errors as $error) {
                $errorMessages[$error->getPropertyPath()] = $error->getMessage();
            }
            return $this->json(['errors' => $errorMessages], 400);
        }

        try {
            $email = (new Email())
                ->from(new Address($data['email'], $data['firstName'].' '.$data['lastName']))
                ->to('jej042817@gmail.com')
                ->replyTo($data['email'])
                ->subject('Nouveau message: ' . $data['subject'])
                ->html($this->renderView('emails/contact.html.twig', [
                    'data' => $data,
                    'ip' => $request->getClientIp(),
                    'userAgent' => $request->headers->get('User-Agent')
                ]));

            $mailer->send($email);

            return $this->json([
                'success' => true,
                'message' => 'Merci pour votre message! Nous vous répondrons bientôt.'
            ]);

        } catch (\Exception $e) {
    $logger->error('Email sending failed', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString(),
        'exception' => $e
    ]);
    
    return $this->json([
        'success' => false,
        'message' => 'Une erreur technique est survenue. Veuillez réessayer plus tard.',
        'error' => $e->getMessage() // En dev seulement
    ], 500);
}
    }
}