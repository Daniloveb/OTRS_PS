$OwnerFIO = "Парфенов Алексей Валерьевич"

$loginname = (get-aduser -Filter "Name -eq '$OwnerFIO'").samaccountname
write-host $loginname