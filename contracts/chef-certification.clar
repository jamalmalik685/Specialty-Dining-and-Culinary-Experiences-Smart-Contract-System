;; Chef Certification Smart Contract
;; Manages chef credentials, certification levels, and specializations

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CHEF-NOT-FOUND (err u101))
(define-constant ERR-CHEF-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-CERTIFICATION-LEVEL (err u103))
(define-constant ERR-INSUFFICIENT-EXPERIENCE (err u104))
(define-constant ERR-INVALID-SPECIALIZATION (err u105))
(define-constant ERR-CERTIFICATION-EXPIRED (err u106))

;; Certification levels (1-5)
(define-constant APPRENTICE u1)
(define-constant SOUS-CHEF u2)
(define-constant HEAD-CHEF u3)
(define-constant EXECUTIVE-CHEF u4)
(define-constant MASTER-CHEF u5)

;; Experience requirements for each level
(define-constant APPRENTICE-EXP u0)
(define-constant SOUS-CHEF-EXP u100)
(define-constant HEAD-CHEF-EXP u500)
(define-constant EXECUTIVE-CHEF-EXP u1500)
(define-constant MASTER-CHEF-EXP u5000)

;; Data structures
(define-map chefs
  principal
  {
    name: (string-ascii 50),
    certification-level: uint,
    experience-points: uint,
    specializations: (list 10 (string-ascii 30)),
    certification-date: uint,
    expiry-date: uint,
    active: bool,
    rating: uint
  }
)

(define-map chef-specializations
  (string-ascii 30)
  {
    description: (string-ascii 100),
    active: bool
  }
)

(define-data-var next-chef-id uint u1)
(define-data-var total-chefs uint u0)

;; Initialize valid specializations
(map-set chef-specializations "Italian" {description: "Italian cuisine specialization", active: true})
(map-set chef-specializations "French" {description: "French cuisine specialization", active: true})
(map-set chef-specializations "Japanese" {description: "Japanese cuisine specialization", active: true})
(map-set chef-specializations "Molecular" {description: "Molecular gastronomy specialization", active: true})
(map-set chef-specializations "Pastry" {description: "Pastry and dessert specialization", active: true})
(map-set chef-specializations "Vegan" {description: "Vegan cuisine specialization", active: true})
(map-set chef-specializations "Seafood" {description: "Seafood specialization", active: true})
(map-set chef-specializations "BBQ" {description: "Barbecue specialization", active: true})

;; Private functions
(define-private (is-valid-certification-level (level uint))
  (and (>= level APPRENTICE) (<= level MASTER-CHEF))
)

(define-private (get-required-experience (level uint))
  (if (is-eq level APPRENTICE) APPRENTICE-EXP
    (if (is-eq level SOUS-CHEF) SOUS-CHEF-EXP
      (if (is-eq level HEAD-CHEF) HEAD-CHEF-EXP
        (if (is-eq level EXECUTIVE-CHEF) EXECUTIVE-CHEF-EXP
          MASTER-CHEF-EXP
        )
      )
    )
  )
)

(define-private (is-valid-specialization (spec (string-ascii 30)))
  (match (map-get? chef-specializations spec)
    specialization (get active specialization)
    false
  )
)

(define-private (validate-specializations (specs (list 10 (string-ascii 30))))
  (fold check-specialization specs true)
)

(define-private (check-specialization (spec (string-ascii 30)) (acc bool))
  (and acc (is-valid-specialization spec))
)

(define-private (is-certification-valid (chef-data {name: (string-ascii 50), certification-level: uint, experience-points: uint, specializations: (list 10 (string-ascii 30)), certification-date: uint, expiry-date: uint, active: bool, rating: uint}))
  (and
    (get active chef-data)
    (> (get expiry-date chef-data) block-height)
  )
)

;; Public functions

;; Register a new chef
(define-public (register-chef (name (string-ascii 50)) (certification-level uint) (specializations (list 10 (string-ascii 30))))
  (let (
    (chef-principal tx-sender)
    (current-time block-height)
    (expiry-time (+ block-height u52560)) ;; Approximately 1 year in blocks
  )
    (asserts! (is-none (map-get? chefs chef-principal)) ERR-CHEF-ALREADY-EXISTS)
    (asserts! (is-valid-certification-level certification-level) ERR-INVALID-CERTIFICATION-LEVEL)
    (asserts! (validate-specializations specializations) ERR-INVALID-SPECIALIZATION)

    (map-set chefs chef-principal {
      name: name,
      certification-level: certification-level,
      experience-points: u0,
      specializations: specializations,
      certification-date: current-time,
      expiry-date: expiry-time,
      active: true,
      rating: u0
    })

    (var-set total-chefs (+ (var-get total-chefs) u1))
    (ok true)
  )
)

;; Update chef experience points
(define-public (add-experience (chef principal) (points uint))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
    (new-experience (+ (get experience-points chef-data) points))
  )
    (asserts! (is-certification-valid chef-data) ERR-CERTIFICATION-EXPIRED)

    (map-set chefs chef (merge chef-data {experience-points: new-experience}))
    (ok new-experience)
  )
)

;; Upgrade chef certification level
(define-public (upgrade-certification (chef principal) (new-level uint))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
    (current-level (get certification-level chef-data))
    (experience (get experience-points chef-data))
    (required-exp (get-required-experience new-level))
  )
    (asserts! (is-eq tx-sender chef) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-certification-level new-level) ERR-INVALID-CERTIFICATION-LEVEL)
    (asserts! (> new-level current-level) ERR-INVALID-CERTIFICATION-LEVEL)
    (asserts! (>= experience required-exp) ERR-INSUFFICIENT-EXPERIENCE)
    (asserts! (is-certification-valid chef-data) ERR-CERTIFICATION-EXPIRED)

    (map-set chefs chef (merge chef-data {
      certification-level: new-level,
      certification-date: block-height,
      expiry-date: (+ block-height u52560)
    }))
    (ok true)
  )
)

;; Renew chef certification
(define-public (renew-certification (chef principal))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender chef) ERR-NOT-AUTHORIZED)
    (asserts! (get active chef-data) ERR-NOT-AUTHORIZED)

    (map-set chefs chef (merge chef-data {
      certification-date: block-height,
      expiry-date: (+ block-height u52560)
    }))
    (ok true)
  )
)

;; Update chef specializations
(define-public (update-specializations (chef principal) (new-specializations (list 10 (string-ascii 30))))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender chef) ERR-NOT-AUTHORIZED)
    (asserts! (validate-specializations new-specializations) ERR-INVALID-SPECIALIZATION)
    (asserts! (is-certification-valid chef-data) ERR-CERTIFICATION-EXPIRED)

    (map-set chefs chef (merge chef-data {specializations: new-specializations}))
    (ok true)
  )
)

;; Update chef rating (only contract owner can do this)
(define-public (update-chef-rating (chef principal) (rating uint))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= rating u5) ERR-INVALID-CERTIFICATION-LEVEL)

    (map-set chefs chef (merge chef-data {rating: rating}))
    (ok true)
  )
)

;; Deactivate chef (suspend certification)
(define-public (deactivate-chef (chef principal))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set chefs chef (merge chef-data {active: false}))
    (ok true)
  )
)

;; Reactivate chef
(define-public (reactivate-chef (chef principal))
  (let (
    (chef-data (unwrap! (map-get? chefs chef) ERR-CHEF-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set chefs chef (merge chef-data {
      active: true,
      certification-date: block-height,
      expiry-date: (+ block-height u52560)
    }))
    (ok true)
  )
)

;; Add new specialization (only contract owner)
(define-public (add-specialization (spec (string-ascii 30)) (description (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set chef-specializations spec {description: description, active: true})
    (ok true)
  )
)

;; Read-only functions

;; Get chef information
(define-read-only (get-chef-info (chef principal))
  (map-get? chefs chef)
)

;; Check if chef is certified and active
(define-read-only (is-chef-certified (chef principal))
  (match (map-get? chefs chef)
    chef-data (is-certification-valid chef-data)
    false
  )
)

;; Get chef certification level
(define-read-only (get-chef-level (chef principal))
  (match (map-get? chefs chef)
    chef-data (some (get certification-level chef-data))
    none
  )
)

;; Get chef experience points
(define-read-only (get-chef-experience (chef principal))
  (match (map-get? chefs chef)
    chef-data (some (get experience-points chef-data))
    none
  )
)

;; Get chef specializations
(define-read-only (get-chef-specializations (chef principal))
  (match (map-get? chefs chef)
    chef-data (some (get specializations chef-data))
    none
  )
)

;; Get chef rating
(define-read-only (get-chef-rating (chef principal))
  (match (map-get? chefs chef)
    chef-data (some (get rating chef-data))
    none
  )
)

;; Get specialization info
(define-read-only (get-specialization-info (spec (string-ascii 30)))
  (map-get? chef-specializations spec)
)

;; Get total number of chefs
(define-read-only (get-total-chefs)
  (var-get total-chefs)
)

;; Check if certification level is valid
(define-read-only (is-valid-level (level uint))
  (is-valid-certification-level level)
)

;; Get experience requirement for level
(define-read-only (get-experience-requirement (level uint))
  (if (is-valid-certification-level level)
    (some (get-required-experience level))
    none
  )
)

;; Check if chef can upgrade to level
(define-read-only (can-upgrade-to-level (chef principal) (target-level uint))
  (match (map-get? chefs chef)
    chef-data
      (let (
        (current-level (get certification-level chef-data))
        (experience (get experience-points chef-data))
        (required-exp (get-required-experience target-level))
      )
        (and
          (is-valid-certification-level target-level)
          (> target-level current-level)
          (>= experience required-exp)
          (is-certification-valid chef-data)
        )
      )
    false
  )
)
