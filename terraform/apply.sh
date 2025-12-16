#!/bin/bash

# Script pour lancer Terraform Apply de manière robuste
# Logs dans /tmp/terraform-apply.log

cd /home/nicog/chat-devops-project/terraform

echo "🚀 TERRAFORM APPLY - DÉMARRAGE" > /tmp/terraform-apply.log
echo "Heure: $(date)" >> /tmp/terraform-apply.log
echo "════════════════════════════════════════" >> /tmp/terraform-apply.log
echo "" >> /tmp/terraform-apply.log

# Lancer terraform apply
terraform apply -auto-approve >> /tmp/terraform-apply.log 2>&1

# Statut final
if [ $? -eq 0 ]; then
    echo "" >> /tmp/terraform-apply.log
    echo "✅ TERRAFORM APPLY RÉUSSI !" >> /tmp/terraform-apply.log
    echo "Heure de fin: $(date)" >> /tmp/terraform-apply.log
else
    echo "" >> /tmp/terraform-apply.log
    echo "❌ TERRAFORM APPLY ÉCHOUÉ" >> /tmp/terraform-apply.log
    echo "Code de sortie: $?" >> /tmp/terraform-apply.log
    echo "Heure de fin: $(date)" >> /tmp/terraform-apply.log
fi
