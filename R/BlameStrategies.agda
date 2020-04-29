module R.BlameStrategies
  (Label : Set)
  where

open import Types
open import R.Values Label
open import Cast Label
open import Error using (Error; return; raise; _>>=_)

open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Data.Empty using (⊥-elim)

record BlameStrategy : Set₁ where
  field
    Injectable : PreType → Set
    ⟦_⟧ : ∀ {S T}
      → Cast S T
      -----
      → Value Injectable S
      → Error Label (Value Injectable T)

module LazyD where
  open import Types
  open import Relation.Nullary using (yes; no)

  I? : PreType → Set
  I? = Same

  apply-cast' : ∀ {P Q} → Value I? (` P) → Cast (` P) (` Q)
    → Error Label (Value I? (` Q))
  apply-cast' v ((` P) ⟹[ l ] (` Q)) with (` P) ⌣? (` Q)
  ... | yes P⌣Q = return (add-proxy I? v ((` P) ⟹[ l ] (` Q)) P⌣Q)
  ... | no ¬P⌣Q = raise l

  ⟦_⟧ : ∀ {S T} → Cast S T → Value I? S → Error Label (Value I? T)
  ⟦ * ⟹[ l ] * ⟧ v = return v
  ⟦ * ⟹[ l ] (` Q) ⟧ (dyn (same P) v) = apply-cast' v ((` P) ⟹[ l ] (` Q))
  ⟦ (` P) ⟹[ l ] * ⟧ v = return (dyn (same P) v)
  ⟦ (` P) ⟹[ l ] (` Q) ⟧ v = apply-cast' v ((` P) ⟹[ l ] (` Q))

LazyDBS : BlameStrategy
LazyDBS = record { Injectable = LazyD.I? ; ⟦_⟧ = LazyD.⟦_⟧ }

module LazyUD where
  open import Types

  I? : PreType → Set
  I? = Ground

  open import Relation.Nullary using (yes; no)
  open import Relation.Binary.PropositionalEquality using (refl)

  project : Value I? * → Label → {Q : PreType} → Ground Q
    → Error Label (Value I? (` Q))
  project (dyn gP v) l gQ with (` unground gP) ≟ (` unground gQ)
  ... | yes refl = return v
  ... | no ¬p = raise l
  
  ⟦_⟧ : ∀ {S T} → Cast S T → Value I? S → Error Label (Value I? T)
  ⟦ *   ⟹[ l ] * ⟧ v = return v
  ⟦ ` P ⟹[ l ] * ⟧ v with ground? P
  ... | yes Pg = return (dyn Pg v)
  ... | no ¬Pg = return (dyn (ground-Ground P)
                             (add-proxy I? v ((` P) ⟹[ l ] (` ground P))
                                        (ground-⌣ P)))
  ⟦ ` P ⟹[ l ] ` Q ⟧ v with (` P) ⌣? (` Q)
  ... | yes p = return (add-proxy I? v ((` P) ⟹[ l ] (` Q)) p)
  ... | no ¬p = raise l
  ⟦ * ⟹[ l ] ` Q ⟧ v with ground? Q
  ⟦ * ⟹[ l ] ` Q ⟧ v | yes Qg = project v l Qg
  ⟦ * ⟹[ l ] ` Q ⟧ v | no ¬Qg
    = project v l (ground-Ground Q) >>= λ u →
      return (add-proxy I? u (` ground Q ⟹[ l ] ` Q) (⌣sym (ground-⌣ Q)))

LazyUDBS : BlameStrategy
LazyUDBS = record { Injectable = LazyUD.I? ; ⟦_⟧ = LazyUD.⟦_⟧ }
