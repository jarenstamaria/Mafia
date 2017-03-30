#lang racket

(require net/http-client
         net/uri-codec
         json
         openssl)

(provide Send-Message-Telegram)

(define Bot-String "")

(define (Send-Message-Telegram Chat-ID Str)
  ;; Sends a Message, Str, to Telegram to the Chat with Chat-ID
  (http-sendrecv "api.telegram.org"
                 (string-append Bot-String"sendMessage")
                 #:ssl? (ssl-secure-client-context)
                 #:method "POST"
                 #:headers (list "Content-Type: application/x-www-form-urlencoded")
                 #:data
                 (alist->form-urlencoded
                  (list (cons 'chat_id (format "~a" Chat-ID))
                        (cons 'text Str)))))
