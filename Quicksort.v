Require Import Coq.Lists.List.
Require Import Coq.Sorting.Sorted.

Module Quicksort.

Lemma split_accto_pivot : forall {A}
                                 (ord : A -> A -> Prop)
                                 (total : forall a b, {ord a b} + {ord b a})
                                 pivot list,
                            {pre | { post |
                             (forall x, In x pre -> ord x pivot) /\
                             (forall x, In x post -> ord pivot x) /\
                             (forall x, In x list <->
                                        In x pre \/ In x post) /\
                             (length pre + length post = length list)}}.
Proof.
  intros A ord total piv list.
  induction list.
  exists nil.
  exists nil.
  split.
  intros x innil.
  inversion innil.
  split.
  intros x innil.
  inversion innil.
  split.
  intros x.
  split.
  intros innil.
  inversion innil.
  intros innil.
  elim innil.
  trivial.
  trivial.
  reflexivity.
  assert ({pre : Datatypes.list A |
           {post : Datatypes.list A |
            (forall x : A, In x pre -> ord x piv) /\
            (forall x : A, In x post -> ord piv x) /\
            (forall x : A, In x list <-> In x pre \/ In x post) /\
            (length pre + length post = length list)}}).
  apply IHlist.
  elim X.
  intros pre' pre_chunk.
  elim pre_chunk.
  intros post' ex'.
  elim ex'.
  intros H H0.
  elim H0.
  intros H1 H2.
  elim H2.
  intros H3 H4.
  elim (total piv a).
  intros opa.
  exists pre'.
  exists (a :: post').
  split.
  auto.
  split.
  intros x inx.
  inversion inx.
  rewrite <- H5.
  apply opa.
  auto.
  split.
  intros x. 
  split.
  intros inx.
  inversion inx.
  apply or_intror.
  rewrite <- H5.
  apply in_eq.
  assert (H6 : In x pre' \/ In x post').
  apply H2.
  apply H5.
  elim H6.
  auto.
  intros inxpost.
  apply or_intror.
  apply in_cons.
  apply inxpost.
  intros in_or.
  elim in_or.
  intros inxpre.
  apply in_cons.
  apply H3.
  auto.
  intros inapost.
  inversion inapost.
  rewrite -> H5.
  apply in_eq.
  apply in_cons.
  apply H3.
  auto.
  replace (length (a :: list)) with (S (length list)).
  replace (length (a :: post')) with (S (length post')).
  rewrite <- plus_n_Sm.
  rewrite -> H4.
  reflexivity.
  reflexivity.
  reflexivity.
  intros oap.
  exists (a :: pre').
  exists post'.
  split.
  intros x inx.
  inversion inx.
  rewrite <- H5.
  apply oap.
  apply H.
  apply H5.
  split.
  auto.
  split.
  intros x. 
  split.
  intros inx.
  inversion inx.
  apply or_introl.
  rewrite <- H5.
  apply in_eq.
  assert (myor : In x pre' \/ In x post').
  apply H3.
  apply H5.
  elim myor.
  intros inxpre.
  apply or_introl.
  apply in_cons.
  apply inxpre.
  auto.
  intros inor.
  elim inor.
  intros inapre.
  inversion inapre.
  rewrite -> H5.
  apply in_eq.
  apply in_cons.
  apply H3.
  auto.
  intro inxpost.
  apply in_cons.
  apply H3.
  auto.
  replace (length (a :: pre')) with (S (length pre')).
  rewrite -> plus_Sn_m.
  rewrite -> H4.
  reflexivity.
  reflexivity.
Qed.

Lemma quicksort_conc_lemma : forall {A}
                                    (ord : A -> A -> Prop)
                                    a b c,
                               Sorted ord a -> Sorted ord (b :: c) -> (forall x, In x a -> ord x b) -> Sorted ord (a ++ (b :: c)).
Proof.
  intros A ord a b c H H0 H1.
  induction a.
  apply H0.
  assert (tmp1 : (a :: a0) ++ b :: c = a :: (a0 ++ b :: c)).
  reflexivity.
  rewrite -> tmp1.
  apply Sorted_cons.
  apply IHa.
  inversion H.
  auto.
  intros x inx.
  apply H1.
  apply in_cons.
  apply inx.
  destruct a0.
  apply HdRel_cons.
  apply H1.
  apply in_eq.
  apply HdRel_cons.
  inversion H.
  inversion H5.
  auto.
Qed.

Theorem quicksort : forall {A}
                           (ord : A -> A -> Prop)
                           (total : forall a b, {ord a b} + {ord b a})
                           L,
                      {L' | (forall x, In x L <-> In x L') /\ Sorted ord L'}.
Proof.
  intros A ord total L.
  refine ((fix f n L (lenc : length L <= n) : {L' | (forall x, In x L <-> In x L') /\ Sorted ord L'} :=
             match n as m return (m = n -> _) with
               | 0 => fun eq => _
               | S m' => fun eq => _
             end eq_refl) (length L) L _).
  rewrite <- eq in lenc.
  destruct L.
  exists nil.
  split.
  intros a.
  split.
  trivial.
  trivial.
  apply Sorted_nil.
  contradict lenc.
  unfold length.
  intros Q.
  inversion Q.

  destruct L.
  exists nil.
  split.
  intros x.
  split.
  trivial.
  trivial.
  apply Sorted_nil.
  assert ({pre | { post |
                   (forall x, In x pre -> ord x a) /\
                   (forall x, In x post -> ord a x) /\
                   (forall x, In x L <->
                              In x pre \/ In x post) /\
                   (length pre + length post = length L)}}).
  apply split_accto_pivot.
  apply total.
  elim X.
  intros pre QQ.
  elim QQ.
  intros post QQQ.
  elim QQQ.
  intros B Bc1.
  elim Bc1.
  intros B0 Bc2.
  elim Bc2.
  intros B1 B2.
  assert (X0 : {post' : list A | (forall x : A, In x post <-> In x post') /\ Sorted ord post'}).
  apply (f m').
  apply Le.le_S_n.
  apply (Le.le_trans _ (length (a :: L))).
  replace (length (a :: L)) with (S (length L)).
  rewrite <- B2.
  auto.
  assert (tmp1 : S (length pre + length post) = length pre + S (length post)).
  auto.
  rewrite -> tmp1.
  apply Plus.le_plus_r.
  auto.
  rewrite -> eq.
  auto.
  elim X0.
  intros post' X1.
  elim X1.
  intros X2 X3.
  assert (Y0 : {pre' : list A | (forall x : A, In x pre <-> In x pre') /\ Sorted ord pre'}).
  apply (f m').
  apply Le.le_S_n.
  apply (Le.le_trans _ (length (a :: L))).
  apply (Le.le_trans _ (length (a :: L))).
  replace (length (a :: L)) with (S (length L)).
  rewrite <- B2.
  assert (tmp1 : S (length pre + length post) = S(length pre) + length post).
  auto.
  rewrite -> tmp1.
  apply Plus.le_plus_l.
  auto.
  auto.
  rewrite -> eq.
  auto.
  elim Y0.
  intros pre' Y1.
  elim Y1.
  intros Y2 Y3.
  exists (pre' ++ (a :: post')).
  split.
  split.
  intros inxal.
  inversion inxal.
  apply in_or_app.
  apply or_intror.
  rewrite <- H.
  apply in_eq.
  assert (In x pre \/ In x post).
  apply B1.
  apply H.
  elim H0.
  intros H1.
  apply in_or_app.
  apply or_introl.
  apply Y2.
  apply H1.
  intros H1.
  apply in_or_app.
  apply or_intror.
  apply in_cons.
  apply X2.
  apply H1.

  intros inx.

  assert (inx' : In x pre' \/ In x (a :: post')).
  apply in_app_or.
  apply inx.
  elim inx'.
  intros inxpre'.
  assert (inxpre : In x pre).
  apply Y2.
  apply inxpre'.
  apply in_cons.
  apply B1.
  auto.

  intros inxpost'.
  inversion inxpost'.
  rewrite <- H.
  apply in_eq.
  apply in_cons.
  assert (inxpost : In x post).
  apply X2.
  apply H.
  apply B1.
  auto.
  apply quicksort_conc_lemma.
  apply Y3.
  apply Sorted_cons.
  apply X3.
  destruct post'.
  apply HdRel_nil.
  apply HdRel_cons.
  apply B0.
  apply X2.
  apply in_eq.
  intros x inxpre'.
  apply B.
  apply Y2.
  apply inxpre'.
  auto.
Qed.

End Quicksort.