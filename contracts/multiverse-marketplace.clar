;; Multiverse Data Marketplace Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-item-not-for-sale (err u102))
(define-constant err-insufficient-balance (err u103))

;; Data Variables
(define-data-var listing-counter uint u0)
(define-map listings uint {
    seller: principal,
    token-id: uint,
    price: uint,
    status: (string-ascii 20)
})

;; Public Functions
(define-public (create-listing (token-id uint) (price uint))
    (let
        (
            (listing-id (+ (var-get listing-counter) u1))
        )
        (asserts! (> price u0) err-invalid-parameters)
        (map-set listings listing-id {
            seller: tx-sender,
            token-id: token-id,
            price: price,
            status: "active"
        })
        (var-set listing-counter listing-id)
        (ok listing-id)
    )
)

(define-public (cancel-listing (listing-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings listing-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get seller listing)) err-invalid-parameters)
        (asserts! (is-eq (get status listing) "active") err-item-not-for-sale)
        (map-set listings listing-id
            (merge listing {
                status: "cancelled"
            })
        )
        (ok true)
    )
)

(define-public (buy-listing (listing-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings listing-id) err-invalid-parameters))
            (buyer tx-sender)
        )
        (asserts! (is-eq (get status listing) "active") err-item-not-for-sale)
        (map-set listings listing-id
            (merge listing {
                status: "sold"
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-listing (listing-id uint))
    (map-get? listings listing-id)
)

(define-read-only (get-listing-count)
    (var-get listing-counter)
)

