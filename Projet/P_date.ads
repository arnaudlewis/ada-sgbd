   package P_Date is
   
      TYPE T_mois IS (JANVIER, FEVRIER, MARS, AVRIL, MAI, JUIN, JUILLET, AOUT, SEPTEMBRE, OCTOBRE, NOVEMBRE, DECEMBRE);
      SUBTYPE T_no_jour IS integer RANGE 1..31;
      SUBTYPE T_annee IS integer RANGE 1..integer'Last;
      TYPE T_date IS private;
   
      function Creation_Date (nojour : T_no_jour; mois : T_mois; an : T_annee) RETURN T_date;
   
      procedure Affectation ( d1 : T_date; d2 : out T_date );
   -- d2 <-- d1
   
      function Today RETURN T_date;
   -- retourne la date du jour qui sera lue à l'ouverture du paquettage
   
      function Jour (d : T_date) RETURN integer;
   -- retourne le numéro du jour
   
      function Mois (d : T_date) RETURN integer;
   -- retourne le numéro du jour
   
      function Annee (d : T_date) RETURN integer;
   -- retourne le numéro du jour
   
      function "<" (d1, d2 : T_date) RETURN boolean;
   -- test d1 < d2
   
      function "=" (d1, d2 : T_date) RETURN boolean;
   -- test d1 = d2
   
      function ">" (d1, d2 : T_date) RETURN boolean;
   -- test d1 > d2
   
      function Date_Lendemain (d : T_date) RETURN T_date;
   -- retourne la date du jour suivant la date d
   
      function "+" (d : T_date;  nbj : integer) RETURN T_date;
   -- ou redéfinition
      function "+" (nbj : integer;  d : T_date) RETURN T_date;
   -- retourne la date égale à d +nbj
   
   
      function "-" (d1, d2 : T_date) RETURN integer;
   -- retourne le nombre de jours entre d2 et d1 ; soit d2 - d1, soit d1 - d2
   
      procedure Lire (d : out T_date);
   -- lit le jour, le mois et l'année et crée la date d avec ces données
   
      procedure Ecrire (d : T_date; chaine:out string);
   -- affiche la date d sous la forme "20 FEVRIER 2002"
   
   
   private
      TYPE T_date IS RECORD
            jj : T_no_jour;
            mm : T_mois;
            aa : T_annee;
         END RECORD;
   
   END P_date;

