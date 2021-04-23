# MTA: Mail Transfers Agents Settings Placement

## POSTFIX

   * Main settings placed by mta name in name of dict.

   * Default Mail Transfer Agent is Postfix. SMTP mailer work via outgoing postfix proxy, which has default placement on the bastion,
     from all each other hosts on your Landscape/Zones of Cloud, sending and processed by postfix send from local via a primary bastion out.
  
   * This way used for typical and basic notification from inside each host system. 
  
   * This a simple and direct way, for delivery any notifications, be still an important part for each complex-system, 
     must contain full necessary notification layer model.
