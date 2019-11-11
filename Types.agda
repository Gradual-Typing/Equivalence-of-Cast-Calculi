module Types where
open import Relation.Nullary using (Dec; yes; no)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; cong)
open import Data.Product using (Σ; _×_ ; Σ-syntax; ∃-syntax; _,_)

infix 100 _⇒_
infix 100 _⊗_
infix 100 _⊕_

mutual
  data Type : Set where
    * : Type
    `_ : (P : PreType) → Type
    
  data PreType : Set where
    U : PreType
    _⇒_ : (S T : Type) → PreType
    _⊗_ : (S T : Type) → PreType
    _⊕_ : (S T : Type) → PreType

data Ground : PreType → Set where
  `U : Ground (U)
  `⇒ : Ground (* ⇒ *)
  `⊗ : Ground (* ⊗ *)
  `⊕ : Ground (* ⊕ *)
  
ground? : (P : PreType) → Dec (Ground P)
ground? U = yes `U
ground? (* ⇒ *) = yes `⇒
ground? (* ⇒ (` P)) = no λ ()
ground? ((` P) ⇒ T₂) = no (λ ())
ground? (* ⊗ *) = yes `⊗
ground? (* ⊗ (` P)) = no (λ ())
ground? ((` P) ⊗ T) = no (λ ())
ground? (* ⊕ *) = yes `⊕
ground? (* ⊕ (` P)) = no (λ ())
ground? ((` P) ⊕ T) = no (λ ())

_≡?_ : (T1 T2 : Type) → Dec (T1 ≡ T2)
* ≡? * = yes refl
* ≡? (` P) = no (λ ())
(` P) ≡? * = no (λ ())
(` U) ≡? (` U) = yes refl
(` U) ≡? (` (T₁ ⇒ T₂)) = no (λ ())
(` U) ≡? (` (T₁ ⊗ T₂)) = no (λ ())
(` U) ≡? (` (T₁ ⊕ T₂)) = no (λ ())
(` (T₁ ⇒ T₂)) ≡? (` U) = no (λ ())
(` (T₁ ⇒ T₂)) ≡? (` (T₃ ⇒ T₄)) with T₁ ≡? T₃ | T₂ ≡? T₄
((` (T₁ ⇒ T₂)) ≡? (` (.T₁ ⇒ .T₂))) | yes refl | yes refl = yes refl
((` (T₁ ⇒ T₂)) ≡? (` (.T₁ ⇒ T₄))) | yes refl | no ¬p = no λ { refl → ¬p refl }
((` (T₁ ⇒ T₂)) ≡? (` (T₃ ⇒ T₄))) | no ¬p | p2 = no λ { refl → ¬p refl }
(` (T₁ ⇒ T₂)) ≡? (` (T₃ ⊗ T₄)) = no (λ ())
(` (T₁ ⇒ T₂)) ≡? (` (T₃ ⊕ T₄)) = no (λ ())
(` (T₁ ⊗ T₂)) ≡? (` U) = no (λ ())
(` (T₁ ⊗ T₂)) ≡? (` (T₃ ⇒ T₄)) = no (λ ())
(` (T₁ ⊗ T₂)) ≡? (` (T₃ ⊗ T₄)) with T₁ ≡? T₃ | T₂ ≡? T₄
((` (T₁ ⊗ T₂)) ≡? (` (.T₁ ⊗ .T₂))) | yes refl | yes refl = yes refl
((` (T₁ ⊗ T₂)) ≡? (` (.T₁ ⊗ T₄))) | yes refl | no ¬p = no λ { refl → ¬p refl }
((` (T₁ ⊗ T₂)) ≡? (` (T₃ ⊗ T₄))) | no ¬p | p2 = no λ { refl → ¬p refl }
(` (T₁ ⊗ T₂)) ≡? (` (T₃ ⊕ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ≡? (` U) = no (λ ())
(` (T₁ ⊕ T₂)) ≡? (` (T₃ ⇒ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ≡? (` (T₃ ⊗ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ≡? (` (T₃ ⊕ T₄)) with T₁ ≡? T₃ | T₂ ≡? T₄
((` (T₁ ⊕ T₂)) ≡? (` (T₃ ⊕ T₄))) | yes refl | yes refl = yes refl
((` (T₁ ⊕ T₂)) ≡? (` (T₃ ⊕ T₄))) | yes refl | no ¬p = no λ { refl → ¬p refl }
((` (T₁ ⊕ T₂)) ≡? (` (T₃ ⊕ T₄))) | no ¬p | p2 = no λ { refl → ¬p refl }
                                                                      
-- consistency

data _~_ : (T1 T2 : Type) → Set where
  *~* : * ~ *
  *~P : ∀ P → * ~ (` P)
  P~* : ∀ P → (` P) ~ *
  ~U : (` U) ~ (` U)
  ~⇒ : ∀ {T1 T2 T3 T4}
    → T1 ~ T3
    → T2 ~ T4
    → (` T1 ⇒ T2) ~ (` T3 ⇒ T4)
  ~⊗ : ∀ {T1 T2 T3 T4}
    → T1 ~ T3
    → T2 ~ T4
    → (` T1 ⊗ T2) ~ (` T3 ⊗ T4)
  ~⊕ : ∀ {T1 T2 T3 T4}
    → T1 ~ T3
    → T2 ~ T4
    → (` T1 ⊕ T2) ~ (` T3 ⊕ T4)

-- shallow consistency

data _⌣_ : (T1 T2 : Type) → Set where
  *⌣* : * ⌣ *
  *⌣P : ∀ P → * ⌣ (` P)
  P⌣* : ∀ P → (` P) ⌣ *
  ⌣U : (` U) ⌣ (` U)
  ⌣⇒ : ∀ {T1 T2 T3 T4} → (` T1 ⇒ T2) ⌣ (` T3 ⇒ T4)
  ⌣⊗ : ∀ {T1 T2 T3 T4} → (` T1 ⊗ T2) ⌣ (` T3 ⊗ T4)
  ⌣⊕ : ∀ {T1 T2 T3 T4} → (` T1 ⊕ T2) ⌣ (` T3 ⊕ T4)

_⌣?_ : ∀ T1 T2 → Dec (T1 ⌣ T2)
* ⌣? * = yes *⌣*
* ⌣? (` P) = yes (*⌣P P)
(` P) ⌣? * = yes (P⌣* P)
(` U) ⌣? (` U) = yes ⌣U
(` U) ⌣? (` (T₁ ⇒ T₂)) = no (λ ())
(` U) ⌣? (` (T₁ ⊗ T₂)) = no (λ ())
(` U) ⌣? (` (T₁ ⊕ T₂)) = no (λ ())
(` (T₁ ⇒ T₂)) ⌣? (` U) = no (λ ())
(` (T₁ ⇒ T₂)) ⌣? (` (T₃ ⇒ T₄)) = yes ⌣⇒
(` (T₁ ⇒ T₂)) ⌣? (` (T₃ ⊗ T₄)) = no (λ ())
(` (T₁ ⇒ T₂)) ⌣? (` (T₃ ⊕ T₄)) = no (λ ())
(` (T₁ ⊗ T₂)) ⌣? (` U) = no (λ ())
(` (T₁ ⊗ T₂)) ⌣? (` (T₃ ⇒ T₄)) = no (λ ())
(` (T₁ ⊗ T₂)) ⌣? (` (T₃ ⊗ T₄)) = yes ⌣⊗
(` (T₁ ⊗ T₂)) ⌣? (` (T₃ ⊕ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ⌣? (` U) = no (λ ())
(` (T₁ ⊕ T₂)) ⌣? (` (T₃ ⇒ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ⌣? (` (T₃ ⊗ T₄)) = no (λ ())
(` (T₁ ⊕ T₂)) ⌣? (` (T₃ ⊕ T₄)) = yes ⌣⊕

⌣refl : ∀ T → T ⌣ T
⌣refl * = *⌣*
⌣refl (` U) = ⌣U
⌣refl (` (T₁ ⇒ T₂)) = ⌣⇒
⌣refl (` (T₁ ⊗ T₂)) = ⌣⊗
⌣refl (` (T₁ ⊕ T₂)) = ⌣⊕

⌣sym : ∀ {S T} → S ⌣ T → T ⌣ S
⌣sym *⌣* = *⌣*
⌣sym (*⌣P P) = P⌣* P
⌣sym (P⌣* P) = *⌣P P
⌣sym ⌣U = ⌣U
⌣sym ⌣⇒ = ⌣⇒
⌣sym ⌣⊗ = ⌣⊗
⌣sym ⌣⊕ = ⌣⊕

⌣unique : ∀ {T1 T2}
  → (p1 p2 : T1 ⌣ T2)
  ---
  → p1 ≡ p2
⌣unique *⌣* *⌣* = refl
⌣unique (*⌣P P) (*⌣P .P) = refl
⌣unique (P⌣* P) (P⌣* .P) = refl
⌣unique ⌣U ⌣U = refl
⌣unique ⌣⇒ ⌣⇒ = refl
⌣unique ⌣⊗ ⌣⊗ = refl
⌣unique ⌣⊕ ⌣⊕ = refl

shallow : ∀ {S T} → S ~ T → S ⌣ T
shallow *~* = *⌣*
shallow (*~P P) = *⌣P P
shallow (P~* P) = P⌣* P
shallow ~U = ⌣U
shallow (~⇒ p p₁) = ⌣⇒
shallow (~⊗ p p₁) = ⌣⊗
shallow (~⊕ p p₁) = ⌣⊕

ground : PreType → PreType
ground U = U
ground (T₁ ⇒ T₂) = * ⇒ *
ground (S ⊗ T) = * ⊗ *
ground (S ⊕ T) = * ⊕ *

ground-Ground : ∀ P → Ground (ground P)
ground-Ground U = `U
ground-Ground (T₁ ⇒ T₂) = `⇒
ground-Ground (S ⊗ T) = `⊗
ground-Ground (S ⊕ T) = `⊕

ground-⌣ : ∀ P → (` P) ⌣ (` (ground P))
ground-⌣ U = ⌣U
ground-⌣ (T₁ ⇒ T₂) = ⌣⇒
ground-⌣ (S ⊗ T) = ⌣⊗
ground-⌣ (S ⊕ T) = ⌣⊕

-- subtype

data _≤_ : Type → Type → Set where

  *≤* : * ≤ *
  
  P≤* : ∀ P → (` P) ≤ *
  
  ≤U : (` U) ≤ (` U)
  
  ≤⇒ : ∀ {T1 T2 T3 T4}
    → T3 ≤ T1
    → T2 ≤ T4
    ---
    → (` T1 ⇒ T2) ≤ (` T3 ⇒ T4)
    
  ≤⊗ : ∀ {T1 T2 T3 T4}
    → T1 ≤ T3
    → T2 ≤ T4
    ---
    → (` T1 ⊗ T2) ≤ (` T3 ⊗ T4)
    
  ≤⊕ : ∀ {T1 T2 T3 T4}
    → T1 ≤ T3
    → T2 ≤ T4
    ---
    → (` T1 ⊕ T2) ≤ (` T3 ⊕ T4)

-- imprecise

data _⊑_ : Type → Type → Set where

  *⊑* : * ⊑ *
  
  P⊑* : ∀ P → (` P) ⊑ *
  
  ⊑U : (` U) ⊑ (` U)
  
  ⊑⇒ : ∀ {T1 T2 T3 T4}
    → T1 ⊑ T3
    → T2 ⊑ T4
    ---
    → (` T1 ⇒ T2) ⊑ (` T3 ⇒ T4)
    
  ⊑⊗ : ∀ {T1 T2 T3 T4}
    → T1 ⊑ T3
    → T2 ⊑ T4
    ---
    → (` T1 ⊗ T2) ⊑ (` T3 ⊗ T4)
    
  ⊑⊕ : ∀ {T1 T2 T3 T4}
    → T1 ⊑ T3
    → T2 ⊑ T4
    ---
    → (` T1 ⊕ T2) ⊑ (` T3 ⊕ T4)

  
