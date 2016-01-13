   with P_date;
   use P_date;

   package P_sgbd is

   -- ====================================================================
   -- ================ declarations des types de base ====================
   -- ====================================================================
   subtype T_String is String(1..19);
   subtype T_dechet is string(1..80);
   type T_Cle is (cp,ce,n);
   Type T_enum is (I,F,S,C,B,D);


   -- ====================================================================
   -- =============== Declarations des structures de type LISTE ==========
   -- ====================================================================
      type T_Donnees;
      type Access_Donnees is access  T_Donnees;
      type T_Donnees (type_donnees:T_enum:=I) is record
            Next: Access_donnees;
            case type_donnees is
               when I=> entier:integer;
               when F=> reel:float;
               when S=> chaine:T_string;
                  taille:integer;
               when C=> carac:character;
               when B=> booleen:boolean;
               when D=> date:T_date;
            end case;
         end record;


      type T_attribut;
      type Access_Attribut is access  T_Attribut;
      type T_Attribut is record
            Nom_Attribut:T_String;
            taille:integer;
            type_attribut : T_enum ;
            Carac_Attribut:T_Cle:=n;
            Contenu_Attribut:Access_Donnees;
            Next: Access_attribut;
         end record;

      Type T_Table;
      type Access_Table is access T_Table;
      type T_Table is record
            Nom_Table:T_String;
            taille:integer;
            Contenu_Table:Access_attribut;
            Next: Access_Table;
         end record;

      type T_Base is record
            Nom_Base:T_String;
            taille:integer;
            Contenu_Base:Access_table;
         end record;

   -- ====================================================================
   -- =============== Declarations des structures (type TABLEAU) =========
   -- ====================================================================

      type T_saveDonnees (type_donnees:T_enum:=I) is record
            case type_donnees is
               when I=> entier:integer;
               when F=> reel:float;
               when S=> chaine:T_string;
                  taille:integer;
               when C=> carac:character;
               when P_sgbd.B=> booleen:boolean;
               when D=> date:T_date;
            end case;
         end record;

      type savedo is array(integer range 1..20) of T_savedonnees;

      type T_saveAttribut is record
            Nom_Attribut:T_String;
            taille:integer;
            type_attribut : T_enum ;
            Carac_Attribut:T_Cle:=n;
            Contenu_Attribut:savedo;
            nb:integer;
         end record;

      type saveat is array(integer range 1..20) of T_saveattribut;

      type T_saveTable is record
            Nom_Table:T_String;
            taille:integer;
            Contenu_Table:saveat;
            nb:integer;
         end record;

      type savetable is array(integer range 1..15) of T_saveTable;

      type T_saveBase is record
            Nom_Base:T_String;
            taille:integer;
            Contenu_Base:savetable;
            nb : integer;
         end record;


   -- ===========================================================================================
   -- ===============================Declaration des fonctions ==================================
   -- ===========================================================================================


   -- ======================================== fonctions sur les fichiers =======================================================================

      procedure create_open(Base:in out T_base; nom_fichier:in out string; taille:in out integer; sortir:in out boolean);
      procedure Create_Base(B:out T_Base; nom_fichier:in out string; taille:in out integer);
      procedure open_base(B:in out T_Base;nom_fic:in out string; taille:in out integer);
      procedure save_base(Ba:in T_Base; nom_fic:in string; taille:integer);
      procedure del_base(nom_fic:string; taille:integer; close:in out boolean);


   -- ======================================== fonctions annexes sur les listes ==================================================================


      function Liste_Vide (F:access_table) return boolean;
      function Liste_Vide (F:access_attribut) return boolean;
      function Liste_Vide(F:access_donnees) return boolean;

      function Queue(F:access_table) return access_table;
      function Queue(F:access_attribut) return access_attribut;
      function Queue(F:access_donnees) return access_donnees;

      function nb_elem(liste_tab:in access_table) return integer;
      function nb_elem(liste_att:in access_attribut) return integer;
      function nb_elem(liste_do:in access_donnees) return integer;


   -- ======================================== fonctions Ajout_fin table/attribut/chaque type donnees =============================================

      procedure Ajout_Fin (F:in out access_table; nom:T_string; taille : integer ;contenu:Access_Attribut);
      procedure Ajout_Fin(F:in out access_attribut; nom:T_string; taille : integer ; type_attribut:T_enum; cle:T_cle;contenu:Access_Donnees);
      procedure Ajout_en_tete(F:in out access_attribut; nom:T_string; taille : integer ; type_attribut: T_enum ; cle : T_Cle; contenu : Access_Donnees);
      procedure Ajout_Fin(F:in out access_donnees; donnees : integer);
      procedure Ajout_Fin(F:in out access_donnees; donnees : character);
      procedure Ajout_Fin(F:in out access_donnees; donnees : T_string; taille:integer);
      procedure Ajout_Fin(Fi:in out access_donnees; donnees : float);
      procedure Ajout_Fin(F:in out access_donnees; donnees : boolean);
      procedure ajout_fin(F:in out access_donnees; donnees:T_date);


   -- ======================================== fonctions de suppression ===========================================================================

      procedure Supprimer (table:in out access_table);
      procedure Supprimer (liste_tab:access_table; table_cible:in out access_table);
      procedure Supprimer_donnees(liste:access_table; table_cible:in out access_table);


   -- ======================================== fonctions d'affichage ==============================================================================

      procedure affiche_table(liste_table : access_table) ;
      procedure affiche_attribut(liste_table :access_table; table_cible:in out access_table);
      procedure affiche_donnees(liste_table :access_table; table_cible: in out access_table);


   -- ======================================== fonctions d'Edition ================================================================================

      procedure edit_table(liste:in out access_table);
      procedure edit_attribut(base: access_table; liste: in out access_table);
      procedure edit_donnees(liste_table: in out access_table);


   -- ======================================== fonctions de gestion dynamique de memoire ==========================================================

      procedure free_tab(liste:in out access_table);
      procedure free_at(liste:in out access_attribut);
      procedure free_do(liste:in out access_donnees);
      procedure detruire_liste_at(liste:in out access_attribut);
      procedure detruire_liste_do(liste:in out access_donnees);

   -- ================================================ fonctions annexes ==========================================================================

      procedure MAJ(nom:in out T_string; taille:in integer);
      procedure MAJ_char(char:in out character);

   end P_Sgbd;
