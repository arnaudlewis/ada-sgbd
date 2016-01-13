   WITH Ada.Text_IO;
   USE  Ada.Text_IO;

   package body P_Date is

      Date_Aujourdhui : T_date;

   --***************************************************************************************
      function Creation_Date (nojour : T_no_jour; mois : T_mois; an : T_annee) RETURN T_date IS
      --***************************************************************************************
         d : T_date;
      begin
         d.jj := nojour;
         d.mm := mois;
         d.aa := an;
         RETURN d;
      end Creation_Date;

   --***************************************************************************************
      procedure Affectation ( d1 : T_date; d2 : out T_date ) IS
      --***************************************************************************************
      -- d2 <-- d1
      begin
         d2 := d1;
      end Affectation;

   --***************************************************************************************
      function Today RETURN T_date IS
      --***************************************************************************************
      -- retourne la date du jour qui sera lue à l'ouverture du paquettage
      begin
         Put_Line ("Saisie de la date du jour");
         Put_Line ("=========================");
         New_Line;
         Lire (Date_Aujourdhui);
         RETURN Date_Aujourdhui;
      end Today;

   --***************************************************************************************
      function Jour (d : T_date) RETURN integer IS
      --***************************************************************************************
      -- retourne le numéro du jour
      begin
         RETURN d.jj;
      end Jour;

   --***************************************************************************************
      function Mois (d : T_date) RETURN integer IS
      --***************************************************************************************
      -- retourne le numéro du jour
      begin
         RETURN T_mois'POS(d.mm) +1;
      end Mois;

   --***************************************************************************************
      function Annee (d : T_date) RETURN integer IS
      --***************************************************************************************
      -- retourne le numéro du jour
      begin
         RETURN d.aa;
      end Annee;

   --***************************************************************************************
      function "<" (d1, d2 : T_date) RETURN boolean IS
      --***************************************************************************************
      -- test d1 < d2
      begin
         RETURN (   (d1.aa < d2.aa)
            OR ( (d1.aa = d2.aa) AND (   (d1.mm < d2.mm)
                                     OR ((d1.mm = d2.mm) AND (d1.jj < d2.jj))
            )   )                     );
      end "<";

   --***************************************************************************************
      function "=" (d1, d2 : T_date) RETURN boolean IS
      --***************************************************************************************
      -- test d1 = d2
      begin
         RETURN ( (d1.jj = d2.jj) AND (d1.mm = d2.mm) AND (d1.aa = d2.aa) );
      end "=";

   --***************************************************************************************
      function ">" (d1, d2 : T_date) RETURN boolean IS
      --***************************************************************************************
      -- test d1 > d2
      begin
         RETURN NOT  ( "<"(d1,d2)  OR "="(d1,d2) );
      end ">";

   --***************************************************************************************
      function Date_Lendemain (d : T_date) RETURN T_date IS
      --***************************************************************************************
      -- retourne la date du jour suivant la date d
         dl : T_date;
      begin
         IF  (d.jj = 31)  AND  (d.mm = T_mois'LAST)
         -- test fin d'année
         THEN
            dl.jj := T_no_jour'First;
            dl.mm := T_mois'FIRST;
            dl.aa := T_annee'SUCC(d.aa);
         ELSE  -- on peut aussi écrire ELSIF sans end if en fin de condition
         -- test fin de mois
            IF    (d.jj = 31)
            OR (    (d.jj = 30)
              AND ( (d.mm = AVRIL) OR (d.mm = JUIN) OR (d.mm = SEPTEMBRE) OR (d.mm = NOVEMBRE) ) )
            OR (    (d.mm = FEVRIER)
              AND ( (d.jj = 29) OR (    (d.jj = 28)
                                    AND NOT (   ((d.aa REM 4 = 0) AND NOT (d.aa REM 100 = 0))
                                             OR (d.aa REM 400 = 0)
             )     )                )    )
            THEN
               dl.jj := T_no_jour'FIRST;
               dl.mm := T_mois'SUCC(d.mm);
               dl.aa := d.aa;
            ELSE
               dl.jj := T_no_jour'SUCC(d.jj);
               dl.mm := d.mm;
               dl.aa := d.aa;
            END IF;
         END IF;
         RETURN dl;
      end Date_Lendemain;

   --***************************************************************************************
      function "+" (d : T_date;  nbj : integer) RETURN T_date IS
      --***************************************************************************************
      -- retourne la date égale à d +nbj
         da : T_date;
      begin
         da := d;
         FOR i IN 1..nbj
         LOOP
            da := Date_Lendemain (da);
         END LOOP;
         RETURN da;
      end "+";

   -- OU redéfinition
   --***************************************************************************************
      function "+" (nbj : integer;  d : T_date) RETURN T_date IS
      --***************************************************************************************
      begin
         RETURN "+" (d, nbj);
      end "+";

   --***************************************************************************************
      function "-" (d1, d2 : T_date) RETURN integer IS
      --***************************************************************************************
      -- retourne le nombre de jours entre d2 et d1 ; soit d2 - d1, soit d1 - d2
         da, db   : T_date;
         nbj : integer;
      begin
         IF "<" (d1,d2)
         THEN
            da := d1;
            db := d2;
         ELSE
            da := d2;
            db := d1;
         END IF;
         nbj := 0;
         WHILE  ( "<" (da,db) )
         LOOP
            nbj := nbj +1;
            da  := Date_Lendemain (da);
         END LOOP;
         RETURN nbj;
      end "-";

   --***************************************************************************************
      procedure Lire (d : out T_date) IS
      --***************************************************************************************
      -- lit le jour, le mois et l'année et crée la date d avec ces données
         ch   : STRING(1..40);
      long : integer;
      begin
      loop
            begin
               Put ("Entrez le numero du jour : ");
               Get_Line (ch, long);
               d.jj := T_no_jour'VALUE(ch(1..long));
               exit;
               exception
                  when others => put_line("Attention saisie incorrecte du jour, Veuillez recommencer."); new_line;
            end;
         end loop;

         loop
            begin
               Put ("Entrez le nom du mois    : ");
               Get_Line (ch, long);
               d.mm := T_mois'VALUE(ch(1..long));
               exit;
               exception
                  when others => put_line("Attention saisie du mois inccorecte, Veuillez recommencer."); new_line;
            end;
         end loop;

         loop
            begin
               Put ("Entrez l'annee           : ");
               Get_Line (ch, long);
               d.aa := T_annee'VALUE(ch(1..long));
               exit;
               exception
                  when others => put_line("Attention Saisie de l'annee incorrecte, Veuillez recommencer."); new_line;
            end;
         end loop;

      end Lire;

   --***************************************************************************************
      procedure Ecrire (d : T_date; chaine:out string) IS
      --***************************************************************************************
      -- affiche la date d sous la forme "20 FEVRIER 2002"
         tmp:string:=T_no_jour'IMAGE(d.jj) & " " &T_mois'IMAGE(d.mm) & " " &T_annee'IMAGE(d.aa);
         taille:integer;
      begin
         taille:=tmp'length;
         chaine(chaine'first..taille):=tmp(1..taille);

      end Ecrire;


   end P_date;

