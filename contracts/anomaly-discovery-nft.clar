;; Anomaly Discovery NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; NFT Definition
(define-non-fungible-token anomaly-discovery uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map token-metadata uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    universe-id: uint,
    anomaly-id: uint,
    discovery-data: (string-utf8 10000),
    discoverer: principal
})

;; Public Functions
(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (universe-id uint) (anomaly-id uint) (discovery-data (string-utf8 10000)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (try! (nft-mint? anomaly-discovery token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            universe-id: universe-id,
            anomaly-id: anomaly-id,
            discovery-data: discovery-data,
            discoverer: tx-sender
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (let
        (
            (owner (unwrap! (nft-get-owner? anomaly-discovery token-id) err-not-token-owner))
        )
        (asserts! (is-eq tx-sender owner) err-not-token-owner)
        (try! (nft-transfer? anomaly-discovery token-id owner recipient))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)
