(in-package :climi)

;;;
;;;  Functions dealing with copying to the clipboard.
;;;

(deftype representation-type-name () '(member :string :html))

(defgeneric copy-to-clipboard-with-port (port sheet clipboard-p object presentation-type)
  (:documentation "Method to be implemented by backends."))

(defmethod copy-to-clipboard-with-port ((port clim:port) (sheet clim:sheet) clipboard-p object presentation-type)
  "Fallback implementation if the implementation does not support a clipboard."
  nil)

(defun copy-to-clipboard (sheet object &key presentation-type)
  "Copy OBJECT to the clipboard.
SHEET is the owner of the clipboard, and it is not guaranteed that the
content of the clipboard will be available after the sheet has been
removed."
  (copy-to-clipboard-with-port (port sheet) sheet t object presentation-type))

(defun copy-to-selection (sheet object &key presentation-type)
  "Copy OBJECT to the selection.
SHEET is the owner of the selection, and it is not guaranteed that the
content of the selection will be available after the sheet has been
removed."
  (copy-to-clipboard-with-port (port sheet) sheet nil object presentation-type))

(defgeneric clear-clipboard-with-port (port sheet clipboard-p))

(defmethod clear-clipboard-with-port (port sheet clipboard-p)
  "Fallback implementation if the implementation does not support a clipboard.."
  nil)

(defun clear-clipboard (sheet)
  (clear-clipboard-with-port (port sheet) sheet t))

(defun clear-selection (sheet)
  (clear-clipboard-with-port (port sheet) sheet nil))

;;;
;;;  The following functions implement the standard API to request
;;;  content from the clipboard.
;;;

(defclass clipboard-send-event (climi::window-event)
  ((content :initarg :content
            :reader clipboard-event-content)
   (type    :initarg :type
            :reader clipboard-event-type)
   (handler :initarg :handler
            :initform nil
            :reader clipboard-event-handler)))

(defgeneric request-clipboard-content-from-port (port pane clipboard-p type handler)
  (:documentation "Backend implementation of REQUEST-CLIPBOARD-CONTENT.")
  (:method ((port clim:port) pane clipboard-p type handler)
    (error "Clipboard not implemented for port: ~s" port)))

(defun request-selection-content (pane type handler)
  (request-clipboard-content-from-port (port pane) pane nil type handler))

(defun request-clipboard-content (pane type handler)
  (request-clipboard-content-from-port (port pane) pane t type handler))

#+(or)
(define-condition clipboard-send ()
  ((event :initarg :event
          :reader event-of)))

(defgeneric deliver-clipboard-message (handler event))

(defmethod clim:dispatch-event :around (pane (event clipboard-send-event))
  (alexandria:if-let ((handler (clipboard-event-handler event)))
    (deliver-clipboard-message handler event)
    (call-next-method)))

#+(or)
(defmethod clim:dispatch-event :around (pane (event clipboard-send-event))
  (log:info "Signalling clipboard send event: ~s" event)
  (call-next-method))