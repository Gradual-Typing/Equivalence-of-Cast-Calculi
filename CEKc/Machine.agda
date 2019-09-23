open import Types

module CEKc.Machine
  (Label : Set)
  (Cast : Type → Type → Set)
  (mk-cast : Label → ∀ T1 T2 → Cast T1 T2)
  where

open import Variables
open import Terms Label
open import CEKc.Values Label Cast

data Cont : Type → Type → Set where
                                                                 
  mt : ∀ {Z}
     ----------
     → Cont Z Z
                 
  cons₁ : ∀ {Γ T1 T2 Z}
    → (E : Env Γ)
    → (e1 : Γ ⊢ T2)
    → (κ : Cont (` T1 ⊗ T2) Z)
    --------
    → Cont T1 Z
    
  cons₂ : ∀ {T1 T2 Z}
    → (v1 : Val T1)
    → (κ : Cont (` T1 ⊗ T2) Z)
    --------
    → Cont T2 Z
                 
  inl :  ∀ {T1 T2 Z}
    → (κ : Cont (` T1 ⊕ T2) Z)
    --------
    → Cont T1 Z
                 
  inr :  ∀ {T1 T2 Z}
    → (κ : Cont (` T1 ⊕ T2) Z)
    --------
    → Cont T2 Z
      
  app₁ : ∀ {Γ T1 T2 Z}
    → (E : Env Γ)
    → (e2 : Γ ⊢ T1)
    → (κ : Cont T2 Z)
    --------
    → Cont (` T1 ⇒ T2) Z
                          
  app₂ : ∀ {T1 T2 Z}
    → (v1 : Val (` T1 ⇒ T2))
    → (κ : Cont T2 Z)
    --------
    → Cont T1 Z
                 
  car : ∀ {T1 T2 Z}
    → (κ : Cont T1 Z)
    -----------
    → Cont (` T1 ⊗ T2) Z
    
  cdr : ∀ {T1 T2 Z}
    → (κ : Cont T2 Z)
    -----------
    → Cont (` T1 ⊗ T2) Z
                          
  case₁ :  ∀ {Γ T1 T2 T3 Z}
    → (E : Env Γ)
    → (e2 : Γ ⊢ ` T1 ⇒ T3)
    → (e3 : Γ ⊢ ` T2 ⇒ T3)
    → (κ : Cont T3 Z)
    --------
    → Cont (` T1 ⊕ T2) Z
    
  case₂ :  ∀ {Γ T1 T2 T3 Z}
    → (E : Env Γ)
    → (v1 : Val (` T1 ⊕ T2))
    → (e3 : Γ ⊢ ` T2 ⇒ T3)
    → (κ : Cont T3 Z)
    --------
    → Cont (` T1 ⇒ T3) Z
    
  case₃ : ∀ {T1 T2 T3 Z}
    → (v1 : Val (` T1 ⊕ T2))
    → (v2 : Val (` T1 ⇒ T3))
    → (κ : Cont T3 Z)
    ----------------
    → Cont (` T2 ⇒ T3) Z

  cast : ∀ {T1 T2 Z}
    → (c : Cast T1 T2)
    → (κ : Cont T2 Z)
    → Cont T1 Z

data State : Type → Set where 
  inspect : ∀ {Γ T1 T3}
    → (e : Γ ⊢ T1)
    → (E : Env Γ)
    → (κ : Cont T1 T3)
    ------------
    → State T3
    
  return : ∀ {T1 T2}
    → (v : Val T1)
    → (κ : Cont T1 T2)
    ------------
    → State T2

  blame : ∀ {T}
    → (l : Label)
    -------
    → State T

  done : ∀ {T}
    → (v : Val T)
    -------
    → State T

module Progress
  (apply-cast : ∀ {T1 T2} → Cast T1 T2 → Val T1 → CastResult T2)
  (cast-dom : ∀ {T1 T2 T3 T4} → Cast (` T1 ⇒ T2) (` T3 ⇒ T4) → Cast T3 T1)
  (cast-cod : ∀ {T1 T2 T3 T4} → Cast (` T1 ⇒ T2) (` T3 ⇒ T4) → Cast T2 T4)
  (cast-car : ∀ {T1 T2 T3 T4} → Cast (` T1 ⊗ T2) (` T3 ⊗ T4) → Cast T1 T3)
  (cast-cdr : ∀ {T1 T2 T3 T4} → Cast (` T1 ⊗ T2) (` T3 ⊗ T4) → Cast T2 T4)
  (cast-inl : ∀ {T1 T2 T3 T4} → Cast (` T1 ⊕ T2) (` T3 ⊕ T4) → Cast T1 T3)
  (cast-inr : ∀ {T1 T2 T3 T4} → Cast (` T1 ⊕ T2) (` T3 ⊕ T4) → Cast T2 T4)
  where

  do-app : ∀ {T1 T2 Z}
    → Val (` T1 ⇒ T2)
    → Val T1
    → Cont T2 Z
    → State Z
  do-app (cast v ⌣⇒ c) rand κ
    = return rand (cast (cast-dom c) (app₂ v (cast (cast-cod c) κ)))
  do-app (fun env b) rand κ
    = inspect b (rand ∷ env) κ

  do-car : ∀ {T1 T2 Z}
    → Val (` T1 ⊗ T2)
    → Cont T1 Z
    → State Z
  do-car (cast v ⌣⊗ c) κ = do-car v (cast (cast-car c) κ)
  do-car (cons v₁ v₂) κ = return v₁ κ

  do-cdr : ∀ {T1 T2 Z}
    → Val (` T1 ⊗ T2)
    → Cont T2 Z
    → State Z
  do-cdr (cast v ⌣⊗ c) κ = do-cdr v (cast (cast-cdr c) κ)
  do-cdr (cons v₁ v₂) κ = return v₂ κ
  
  do-case' : ∀ {T1 T2 Z}
    → Val (` T1 ⊕ T2)
    → Cont T1 Z
    → Cont T2 Z
    → State Z
  do-case' (cast v ⌣⊕ c) k1 k2
    = do-case' v (cast (cast-inl c) k1) (cast (cast-inr c) k2)
  do-case' (inl v) k1 k2 = return v k1
  do-case' (inr v) k1 k2 = return v k2

  do-case : ∀ {T1 T2 T3 Z}
    → Val (` T1 ⊕ T2)
    → Val (` T1 ⇒ T3)
    → Val (` T2 ⇒ T3)
    → Cont T3 Z
    → State Z
  do-case v1 v2 v3 k = do-case' v1 (app₂ v2 k) (app₂ v3 k)

  do-cast : ∀ {T1 T2 Z}
    → Cast T1 T2
    → Val T1
    → Cont T2 Z
    → State Z
  do-cast c v k with apply-cast c v
  ... | succ v₁ = return v₁ k
  ... | fail l₁ = blame l₁

  progress : {T : Type} → State T → State T
  progress (inspect (var x) E κ) = return (E [ x ]) κ
  progress (inspect sole E κ) = return sole κ
  progress (inspect (lam T1 T2 e) E κ) = return (fun E e) κ
  progress (inspect (cons e e₁) E κ) = inspect e E (cons₁ E e₁ κ)
  progress (inspect (inl e) E κ) = inspect e E (inl κ)
  progress (inspect (inr e) E κ) = inspect e E (inr κ)
  progress (inspect (app e e₁) E κ) = inspect e E (app₁ E e₁ κ) 
  progress (inspect (car e) E κ) = inspect e E (car κ)
  progress (inspect (cdr e) E κ) = inspect e E (cdr κ)
  progress (inspect (case e e₁ e₂) E κ) = inspect e E (case₁ E e₁ e₂ κ)
  progress (inspect (cast l T1 T2 e) E κ) = inspect e E (cast (mk-cast l T1 T2) κ)
  progress (return v mt) = done v
  progress (return v (cons₁ E e1 κ)) = inspect e1 E (cons₂ v κ)
  progress (return v (cons₂ v1 κ)) = return (cons v1 v) κ
  progress (return v (inl κ)) = return (inl v) κ
  progress (return v (inr κ)) = return (inr v) κ
  progress (return v (app₁ E e2 κ)) = inspect e2 E (app₂ v κ)
  progress (return v (app₂ v1 κ)) = do-app v1 v κ
  progress (return v (car κ)) = do-car v κ
  progress (return v (cdr κ)) = do-cdr v κ
  progress (return v (case₁ E e2 e3 κ)) = inspect e2 E (case₂ E v e3 κ)
  progress (return v (case₂ E v1 e3 κ)) = inspect e3 E (case₃ v1 v κ)
  progress (return v (case₃ v1 v2 κ)) = do-case v1 v2 v κ
  progress (return v (cast c κ)) = do-cast c v κ
  progress (blame l) = blame l
  progress (done v) = done v
  