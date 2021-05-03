(set-logic AUFNIRA)
;;; generated by SMT-LIB2 driver
;;; SMT-LIB2: integer arithmetic
(declare-sort uni 0)

(declare-sort ty 0)

(declare-fun sort (ty uni) Bool)

(declare-fun witness (ty) uni)

;; witness_sort
  (assert (forall ((a ty)) (sort a (witness a))))

(declare-fun int () ty)

(declare-fun real () ty)

(declare-fun infix_lseqas (Real Real) Bool)

(declare-fun from_int (Int) Real)

(declare-sort t 0)

(declare-fun t1 () ty)

(declare-fun tzero () t)

(declare-fun tone () t)

(declare-fun prefix_mndt (t) t)

(declare-fun infix_mndt (t t) t)

(declare-fun infix_sldt (t t) t)

(declare-fun infix_pldt (t t) t)

(declare-fun infix_asdt (t t) t)

(declare-fun infix_lseqdt (t t) Bool)

(declare-fun infix_lsdt (t t) Bool)

(declare-fun inv (t) t)

;; Inverse
  (assert
  (forall ((x t)) (=> (not (= x tzero)) (= (infix_asdt x (inv x)) tone))))

;; div_def
  (assert
  (forall ((x t) (y t))
  (=> (not (= y tzero)) (= (infix_sldt x y) (infix_asdt x (inv y))))))

;; absorbinf_zero
  (assert (forall ((x t)) (= (infix_asdt x tzero) tzero)))

;; assoc_mul_div
  (assert
  (forall ((x t) (y t) (z t))
  (=> (not (= z tzero))
  (= (infix_sldt (infix_asdt x y) z) (infix_asdt x (infix_sldt y z))))))

(declare-fun r_to_t (Real) t)

(declare-fun real_part (t) Real)

(declare-fun im_part (t) Real)

(declare-fun real_ (t) Bool)

;; real__def
  (assert (forall ((x t)) (= (real_ x) (= (im_part x) 0.0))))

;; Inf_eq_def
  (assert
  (forall ((x t) (y t))
  (= (infix_lseqdt x y)
  (or
  (and (real_ x) (and (real_ y) (infix_lseqas (real_part x) (real_part y))))
  (= x y)))))

;; zeroLessOne
  (assert (infix_lseqdt tzero tone))

;; compat_order_mult
  (assert
  (forall ((x t) (y t) (z t))
  (=> (infix_lseqdt x y)
  (=> (real_ x)
  (=> (real_ y)
  (=> (real_ z)
  (=> (infix_lseqdt tzero z) (infix_lseqdt (infix_asdt x z)
  (infix_asdt y z)))))))))

(declare-fun i_to_t (Int) t)

;; i_to_t_def
  (assert (forall ((i Int)) (= (i_to_t i) (r_to_t (from_int i)))))

;; i_to_t_zero
  (assert (= (i_to_t 0) tzero))

(declare-fun set (ty) ty)

(declare-fun mem (ty uni uni) Bool)

(declare-fun is_empty (ty uni) Bool)

(declare-fun inver (ty uni) uni)

;; inver_sort
  (assert (forall ((im ty)) (forall ((x uni)) (sort im (inver im x)))))

(declare-fun infix_mngt (ty ty) ty)

;; get_non_empty
  (assert
  (forall ((a ty))
  (forall ((s uni))
  (=> (not (is_empty a s)) (exists ((e uni)) (and (sort a e) (mem a e s)))))))

(declare-fun cpower (t Int) t)

;; cpower_inv
  (assert
  (forall ((e t) (i Int))
  (= (infix_asdt (cpower e i) (cpower e (- i))) tone)))

;; cpower_plus_one
  (assert
  (forall ((e t) (i Int)) (= (cpower e (+ i 1)) (infix_asdt (cpower e i) e))))

;; non_zero_cpower_pos
  (assert
  (forall ((i t) (n Int))
  (=> (not (= i tzero)) (=> (<= 0 n) (not (= (cpower i n) tzero))))))

;; zero_cpower_pos
  (assert (forall ((n Int)) (=> (< 0 n) (= (cpower tzero n) tzero))))

;; growing_exp_pos
  (assert
  (forall ((k t) (m Int) (n Int))
  (=> (infix_lseqdt tone k)
  (=> (and (<= 0 m) (<= m n)) (infix_lseqdt (cpower k m) (cpower k n))))))

;; growing_exp
  (assert
  (forall ((k t) (m Int) (n Int))
  (=> (infix_lseqdt tone k)
  (=> (<= m n) (infix_lseqdt (cpower k m) (cpower k n))))))

;; strict_growing_exp
  (assert
  (forall ((k t) (m Int) (n Int))
  (=> (infix_lsdt tone k)
  (=> (< m n) (infix_lsdt (cpower k m) (cpower k n))))))

(declare-fun exp (t) t)

(declare-fun x () t)

(declare-fun y () Int)

;; H
  (assert
  (ite (<= 0 y) (= (exp (infix_asdt x (i_to_t y))) (cpower (exp x) y))
  (= (exp (infix_asdt x (i_to_t (- y)))) (cpower (exp x) (- y)))))

(assert
;; h
  (not (= tone tzero)))
(check-sat)