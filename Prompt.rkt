#lang racket

(require net/http-client
         net/uri-codec
         json
         openssl)

(provide Send-Message-Telegram)

(define Bot-String "")
(define Bot-Name "")
(define Last-Update-ID -1)

(define (Send-Message-Telegram Chat-ID Str)
  ;; Sends a Message, Str, to Telegram to the Chat with Chat-ID
  (http-sendrecv "api.telegram.org"
                 (string-append "/bot" Bot-String "/sendMessage")
                 #:ssl? (ssl-secure-client-context)
                 #:method "POST"
                 #:headers (list "Content-Type: application/x-www-form-urlencoded")
                 #:data
                 (alist->form-urlencoded
                  (list (cons 'chat_id (format "~a" Chat-ID))
                        (cons 'text Str)))))

(define (Get-Updates-Telegram)
  ;; Returns the list of updates
  (define-values (status headers data)
    (http-sendrecv "api.telegram.org"
                   (string-append "/bot" Bot-String "/getUpdates")
                   #:ssl? (ssl-secure-client-context)
                   #:method "POST"
                   #:headers (list "Content-Type: application/x-www-form-urlencoded")
                   #:data
                   (alist->form-urlencoded
                    (list (cons 'offset (format "~a" (+ Last-Update-ID 1)))
                          (cons 'timeout "1")))))
  (let* ([matches (regexp-match #px"\\s([^\\s]+)\\s+(.*)" (bytes->string/utf-8 status))]
         [status-code (string->number (list-ref matches 1))]
         [status-class (quotient status-code 100)]
         [status-message(list-ref matches 2)])
    (if (= status-class 2)
        (let ([result (string->jsexpr (port->string data))])
          (if (hash-ref result 'ok)
              (hash-ref result 'result)
              (list)))
        (list))))

(define (Handle-Update Update)
  ;; Handles the update passed to this method
  (when (hash-has-key? Update 'message)
    (let* ([message (hash-ref Update 'message)]
           [matches (regexp-match (pregexp (format "\\s*/join(@~a)?(\\s|$)" Bot-Name)) message)])
      (when matches
        (Player-Join (hash-ref (hash-ref (hash-ref Update 'message) 'chat) 'id))))))

(define (Player-Join Chat-ID)
  (print Chat-ID))