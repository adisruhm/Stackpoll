(define-data-var poll-counter uint u0)

;; Poll metadata
(define-map polls
  {id: uint}
  {
    creator: principal,
    title: (string-ascii 80),
    description: (string-ascii 200),
    options: (list 8 (string-ascii 40)),
    start-block: uint,
    end-block: uint,
    finalized: bool
  }
)

;; Vote counts: (poll-id, option-index) -> count
(define-map poll-votes
  {id: uint, index: uint}
  {count: uint}
)

;; Tracks if voter already voted: (poll-id, voter)
(define-map voters
  {id: uint, voter: principal}
  {voted: bool}
)

;; ----------------------------
;; HELPER FUNCTIONS
;; ----------------------------

(define-private (is-active (p uint))
  (let (
        (poll (unwrap! (map-get? polls {id: p}) (err u404)))
        (h stacks-block-height)
       )
    (ok (and (>= h (get start-block poll))
             (<= h (get end-block poll))
             (not (get finalized poll))))
  )
)

(define-private (only-creator (p uint))
  (let ((poll (unwrap! (map-get? polls {id: p}) (err u404))))
    (asserts! (is-eq tx-sender (get creator poll)) (err u403))
    (ok true)
  )
)

;; ----------------------------
;; PUBLIC FUNCTIONS
;; ----------------------------

;; Create a new poll
(define-public (create-poll
    (title (string-ascii 80))
    (description (string-ascii 200))
    (options (list 8 (string-ascii 40)))
    (start-block uint)
    (end-block uint)
  )
  (begin
    (asserts! (< start-block end-block) (err u400))
    (asserts! (> (len options) u1) (err u401))

    (var-set poll-counter (+ (var-get poll-counter) u1))
    (let ((id (var-get poll-counter)))
      (map-set polls {id: id}
        {
          creator: tx-sender,
          title: title,
          description: description,
          options: options,
          start-block: start-block,
          end-block: end-block,
          finalized: false
        }
      )
      (ok id)
    )
  )
)

;; Cast a vote
(define-public (vote (poll-id uint) (choice uint))
  (let (
        (poll (unwrap! (map-get? polls {id: poll-id}) (err u404)))
        (voter-key {id: poll-id, voter: tx-sender})
        (has-voted (map-get? voters voter-key))
       )
    ;; Check poll is active
    (asserts! (unwrap! (is-active poll-id) (err u405)) (err u406))

    ;; Ensure option index is valid
    (asserts! (< choice (len (get options poll))) (err u402))

    ;; Prevent double voting
    (asserts! (not (is-some has-voted)) (err u407))

    ;; Mark voter as voted
    (map-set voters voter-key {voted: true})

    ;; Increment vote count
    (let (
          (vote-key {id: poll-id, index: choice})
          (current (default-to {count: u0} (map-get? poll-votes vote-key)))
         )
      (map-set poll-votes vote-key {count: (+ (get count current) u1)})
    )
    (ok true)
  )
)

;; Finalize poll after end-block
(define-public (finalize-poll (poll-id uint))
  (begin
    (unwrap! (only-creator poll-id) (err u403))
    (let ((poll (unwrap! (map-get? polls {id: poll-id}) (err u404))))
      ;; Ensure poll has ended
      (asserts! (> stacks-block-height (get end-block poll)) (err u408))
      
      ;; Finalize poll
      (map-set polls {id: poll-id} (merge poll {finalized: true}))
      (ok true)
    )
  )
)

;; Get vote count for poll option
(define-read-only (get-votes (poll-id uint) (choice uint))
  (let (
        (result (map-get? poll-votes {id: poll-id, index: choice}))
       )
    (ok (get count (default-to {count: u0} result)))
  )
)

;; Get poll metadata
(define-read-only (get-poll (poll-id uint))
  (map-get? polls {id: poll-id})
)
