open import Types

module HCCastInterface
  (Label : Set)
  where
open import Relation.Nullary using (Dec; yes; no)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Empty using (⊥-elim)

open import HCCast Label
open import Terms Label Cast

mutual
  seq : Label → ∀ {T1 T2 T3 T4} → Cast T1 T2 → Cast T3 T4 →
    Cast T1 T4
  -- here ℓ is the label that associates with all casts in the middle
  seq ℓ id⋆ id⋆ =
    id⋆
  seq ℓ id⋆ (↷ ε b t) =
    ↷ (⁇ ℓ) b t
  seq ℓ id⋆ (↷ (⁇ l) b t) =
    ↷ (⁇ l) b t
  seq ℓ (↷ h b (⊥ l)) c2 =
    ↷ h b (⊥ l)
  -- now t is either ε or ⁇
  seq ℓ (↷ h b t) id⋆ =
    ↷ h b ‼
  seq ℓ (↷ h b t) (↷ ε b₁ t₁) =
    seq-body ℓ h b b₁ t₁
  seq ℓ (↷ h b t) (↷ (⁇ l) b₁ t₁) =
    seq-body l h b b₁ t₁
  
  seq-body : ∀ {T1 T2 P1 P2 P3 P4}
    → Label
    → Head P1 T1
    → Body P1 P2
    → Body P3 P4
    → Tail P4 T2
    -------------
    → Cast T1 T2
  seq-body {P2 = P2} {P3 = P3} ℓ h b b₁ t with (` P2) ⌣? (` P3)
  seq-body ℓ h U U t | yes ⌣U = ↷ h U t
  seq-body ℓ h (c₁ ⇒ c₂) (c₃ ⇒ c₄) t | yes ⌣⇒ =
    ↷ h (seq ℓ c₃ c₁ ⇒ seq ℓ c₂ c₄) t
  seq-body ℓ h (c₁ ⊗ c₂) (c₃ ⊗ c₄) t | yes ⌣⊗ =
    ↷ h (seq ℓ c₁ c₃ ⊗ seq ℓ c₂ c₄) t
  seq-body ℓ h (c₁ ⊕ c₂) (c₃ ⊕ c₄) t | yes ⌣⊕ =
    ↷ h (seq ℓ c₁ c₃ ⊕ seq ℓ c₂ c₄) t
  seq-body ℓ h b b₁ t | no ¬p = ↷ h b (⊥ ℓ)

mk-seq : ∀ {T1 T2 T3} → Cast T1 T2 → Cast T2 T3 → Cast T1 T3
mk-seq id⋆ c =
  c
mk-seq (↷ h b (⊥ l)) c2 =
  ↷ h b (⊥ l)
mk-seq (↷ h U ε) (↷ ε U t) =
  ↷ h U t
mk-seq (↷ h (c₁ ⇒ c₂) ε) (↷ ε (c₃ ⇒ c₄) t) =
  ↷ h (mk-seq c₃ c₁ ⇒ mk-seq c₂ c₄) t
mk-seq (↷ h (c₁ ⊗ c₂) ε) (↷ ε (c₃ ⊗ c₄) t) =
  ↷ h (mk-seq c₁ c₃ ⊗ mk-seq c₂ c₄) t
mk-seq (↷ h (c₁ ⊕ c₂) ε) (↷ ε (c₃ ⊕ c₄) t) =
  ↷ h (mk-seq c₁ c₃ ⊕ mk-seq c₂ c₄) t
mk-seq (↷ h b ‼) id⋆ =
  ↷ h b ‼
mk-seq (↷ h b ‼) (↷ (⁇ l) b₁ t) =
  seq-body l h b b₁ t

mk-id : ∀ T → Cast T T
mk-id ⋆ = id⋆
mk-id (` U) = ↷ ε U ε
mk-id (` (T₁ ⇒ T₂)) = ↷ ε (mk-id T₁ ⇒ mk-id T₂) ε
mk-id (` (T₁ ⊗ T₂)) = ↷ ε (mk-id T₁ ⊗ mk-id T₂) ε
mk-id (` (T₁ ⊕ T₂)) = ↷ ε (mk-id T₁ ⊕ mk-id T₂) ε

mk-cast : Label → ∀ T1 T2 → Cast T1 T2
mk-cast ℓ ⋆ ⋆ = id⋆
mk-cast ℓ ⋆ (` U) = ↷ (⁇ ℓ) U ε
mk-cast ℓ ⋆ (` (T₁ ⇒ T₂)) = ↷ (⁇ ℓ) (mk-cast ℓ T₁ T₂ ⇒ mk-cast ℓ T₁ T₂) ε
mk-cast ℓ ⋆ (` (T₁ ⊗ T₂)) = ↷ (⁇ ℓ) (mk-cast ℓ T₂ T₁ ⊗ mk-cast ℓ T₁ T₂) ε
mk-cast ℓ ⋆ (` (T₁ ⊕ T₂)) = ↷ (⁇ ℓ) (mk-cast ℓ T₂ T₁ ⊕ mk-cast ℓ T₁ T₂) ε
mk-cast ℓ (` U) ⋆ = ↷ ε U ‼
mk-cast ℓ (` (T₁ ⇒ T₂)) ⋆ = ↷ ε (mk-cast ℓ T₂ T₁ ⇒ mk-cast ℓ T₂ T₁) ‼
mk-cast ℓ (` (T₁ ⊗ T₂)) ⋆ = ↷ ε (mk-cast ℓ T₁ T₂ ⊗ mk-cast ℓ T₂ T₁) ‼
mk-cast ℓ (` (T₁ ⊕ T₂)) ⋆ = ↷ ε (mk-cast ℓ T₁ T₂ ⊕ mk-cast ℓ T₂ T₁) ‼
mk-cast ℓ (` U) (` U) = ↷ ε U ε
mk-cast ℓ (` (T₁ ⇒ T₂)) (` (T₃ ⇒ T₄)) = ↷ ε (mk-cast ℓ T₃ T₁ ⇒ mk-cast ℓ T₂ T₄) ε
mk-cast ℓ (` (T₁ ⊗ T₂)) (` (T₃ ⊗ T₄)) = ↷ ε (mk-cast ℓ T₁ T₃ ⊗ mk-cast ℓ T₂ T₄) ε
mk-cast ℓ (` (T₁ ⊕ T₂)) (` (T₃ ⊕ T₄)) = ↷ ε (mk-cast ℓ T₁ T₃ ⊕ mk-cast ℓ T₂ T₄) ε
mk-cast ℓ (` U) (` P₁) = ↷ ε U (⊥ ℓ)
mk-cast ℓ (` (T₁ ⇒ T₂)) (` P₁) = ↷ ε (mk-id T₁ ⇒ mk-id T₂) (⊥ ℓ)
mk-cast ℓ (` (T₁ ⊗ T₂)) (` P₁) = ↷ ε (mk-id T₁ ⊗ mk-id T₂) (⊥ ℓ)
mk-cast ℓ (` (T₁ ⊕ T₂)) (` P₁) = ↷ ε (mk-id T₁ ⊕ mk-id T₂) (⊥ ℓ)

apply-tail : ∀ {P T} → Tail P T → Val (` P) → CastResult T
apply-tail ε v = succ v
apply-tail ‼ v = succ (inj _ v)
apply-tail (⊥ l) v = fail l

apply-cast : ∀ {T1 T2} → Cast T1 T2 → Val T1 → CastResult T2
apply-cast id⋆ v =
  succ v
apply-cast (↷ ε U t) sole =
  apply-tail t sole
apply-cast (↷ ε (c₁ ⇒ c₂) t) (fun E c₃ b c₄) =
  apply-tail t (fun E (mk-seq c₁ c₃) b (mk-seq c₄ c₂))
apply-cast (↷ ε (c₁ ⊗ c₂) t) (cons v₁ v₂) =
  apply-cast c₁ v₁ >>= λ u₁ →
  apply-cast c₂ v₂ >>= λ u₂ →
  apply-tail t (cons u₁ u₂)
apply-cast (↷ ε (c₁ ⊕ c₂) t) (inl v) =
  apply-cast c₁ v >>= λ u →
  apply-tail t (inl u)
apply-cast (↷ ε (c₁ ⊕ c₂) t) (inr v) =
  apply-cast c₂ v >>= λ u →
  apply-tail t (inr u)
apply-cast (↷ {P = P1} (⁇ l) b t) (inj P2 v) =
  apply-cast (mk-seq (mk-cast l (` P2) (` P1)) (↷ ε b t)) v
