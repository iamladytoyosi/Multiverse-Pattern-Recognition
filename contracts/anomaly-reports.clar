;; Anomaly Reports Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var anomaly-counter uint u0)
(define-map anomalies uint {
    universe-id: uint,
    observation-id: uint,
    description: (string-utf8 1000),
    severity: uint,
    reporter: principal,
    status: (string-ascii 20)
})

;; Public Functions
(define-public (report-anomaly (universe-id uint) (observation-id uint) (description (string-utf8 1000)) (severity uint))
    (let
        (
            (anomaly-id (+ (var-get anomaly-counter) u1))
        )
        (asserts! (and (>= severity u1) (<= severity u10)) err-invalid-parameters)
        (map-set anomalies anomaly-id {
            universe-id: universe-id,
            observation-id: observation-id,
            description: description,
            severity: severity,
            reporter: tx-sender,
            status: "reported"
        })
        (var-set anomaly-counter anomaly-id)
        (ok anomaly-id)
    )
)

(define-public (update-anomaly-status (anomaly-id uint) (new-status (string-ascii 20)))
    (let
        (
            (anomaly (unwrap! (map-get? anomalies anomaly-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (or (is-eq new-status "verified") (is-eq new-status "resolved") (is-eq new-status "false-positive")) err-invalid-parameters)
        (ok (map-set anomalies anomaly-id
            (merge anomaly {
                status: new-status
            })
        ))
    )
)

;; Read-only Functions
(define-read-only (get-anomaly (anomaly-id uint))
    (map-get? anomalies anomaly-id)
)

(define-read-only (get-anomaly-count)
    (var-get anomaly-counter)
)

