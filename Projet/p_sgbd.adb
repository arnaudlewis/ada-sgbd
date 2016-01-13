
With Simple_IO,P_date,text_IO, Sequential_IO, unchecked_deallocation;
use Simple_IO, P_date;

package body P_Sgbd is

   -- =================================instanciation du paquatage sequential_IO pour la gestion de fichiers==========================================
      package P_fichier is new sequential_IO(Element_Type => T_saveBase);
      subtype T_fichier is P_fichier.File_Type;
      Fic:T_fichier;
      use P_fichier;

   -- =================================instanciation des procedures generiques de liberation de la mémoire===========================================
      procedure free_table is new unchecked_deallocation(T_Table, access_table);
      procedure free_attribut is new unchecked_deallocation(T_attribut, access_attribut);
      procedure free_donnees is new unchecked_deallocation(T_donnees, access_donnees);



   -- ===============================================================================================================================================
   -- ================================================ fonctions sur les fichiers ===================================================================
   -- ===============================================================================================================================================


   -- ========================================================= create_open =========================================================================
   -- Réalisé par Denis et Arnaud

   procedure create_open(Base:in out T_base; nom_fichier:in out string; taille:in out integer; sortir:in out boolean) is
      char:character;
      nom:T_string:=(others=>' ');
      ch_tmp:T_dechet:=(others=>' ');
   begin
      new_line; new_line;
      Put_line("***************** SGBD ***************** ");                  -- affichage du menu de démarrage
         loop
            begin
               Put_line("C : Creer une nouvelle base");
               Put_line("O : Ouvrir une base existante");
               Text_io.Get_Immediate(char);                                      -- Get immediate pour pour plus de confort
               MAJ_char(char);                                                   -- on converti le caractère en majuscule pour éviter des soucis de casse
               case char is
                  when 'C' => create_base(Base,nom_fichier,taille);               -- si on veut créer une base, on appelle la fonction create
               when 'O' =>
                  taille:=0;
                  while(taille<1 or taille>19) loop
                     put_line("--OUVRIR UNE BASE EXISTANTE --");         -- sinon on demande quel fichier il veut ouvrir
                     get_line(ch_tmp,taille);
                  end loop;
                     nom(1..taille):=ch_tmp(1..taille);
                     nom_fichier(nom_fichier'first..taille+6):="f_" & nom(1..taille) & ".dat";          -- on rajoute a la chaine le format qu'on a choisi cad "f_NOM.dat"
                     taille:=taille+6;                                            -- la taille augmente de 6 après le rajout
                     open_base(Base,nom_fichier,taille);                          -- on appelle la foncrion pour ouvrir le fichier

                  when others=> raise Simple_IO.data_error;
               end case;
            exit;
         exception
            when Simple_IO.data_error => put_line("Saisie incorrecte");
            when Simple_IO.name_error =>

                 put_line("WARNING - BASE INEXISTANTE");  -- si le fichier n'existe pas, on gère l'exception en demandant si l'user veut créer une base avec ce nouveau nom
                     put_line("Souhaitez vous créer cette base (Y/N)?");
                     get(char);
                     MAJ_char(char);
                     case char is
                        when 'Y' => create_base(Base,nom_fichier,taille);           -- on appelle la fction créer avec ce nouveau nom
                           exit;
                        when 'N' => sortir:=true;                                   -- sinon sortir passe a true pour sortir de la boucle dans le pgme principal
                           exit;
                        when others => put_line("Saisie inccorecte");
               end case;
               when Simple_IO.End_error => put_line("Erreur de fichier !");

            end;
         end loop;
      end create_open;


   -- ================================================== create_base ========================================================================
   -- Réalisé par Denis et Arnaud

      procedure Create_Base(B:out T_Base; nom_fichier:in out string; taille:in out integer) is
      nom:T_string:=(others=>' ');
      ch_tmp:T_dechet:=(others=>' ');
      begin
         if taille=0 then         -- car le nom peut déjà être choisi si l'user est passé par "ouvrir une base" et que le fichier n'existe pas, si il n'est pas choisi : saisi du nom
         while(taille<1 or taille>19) loop
            put_line("-- NOM DE LA BASE A CREER --");
            get_line(ch_tmp,taille);
         end loop;
            nom(1..taille):=ch_tmp(1..taille);
            B.Nom_Base:=nom;           -- affectation du nom & taille dans la structure
            B.taille:=taille;
            nom_fichier(nom_fichier'first..taille+6):="f_" & nom(nom'first..taille) & ".dat";       -- on formate le nom de base pour creer le fichier
            taille:=taille+6;               -- +6 car on a rajouter "f_" et ".dat"
         end if;

         create(File=>fic,Name=>nom_fichier(nom_fichier'first..taille));         -- on créer le fichier avec le nom formaté

         close(Fic);   -- on ferme le fichier
      end create_base;

   -- ===================================================== Open _base ====================================================================
   -- Réalisé par Denis et Arnaud

      procedure open_base(B:in out T_Base;nom_fic:in out String; taille:in out integer) is
         sb:T_saveBase;
         act:access_table;
         aa:access_attribut;
         compteur : integer;
         compt : integer;

      begin
         open(file=>fic,mode=>P_fichier.in_file,name=>nom_fic(nom_fic'first..taille));  -- on ouvre le fichier voulu
         read(fic,sb);             -- puis on le lit en stockant la structure principale contenant toute la base dans la variable "sb"


         -- Pour toutes les opérations qui suivent, on "transfert" les données stockées dans les structures venant du tableau DANS nos structures de travail (fonctionnant avec des listes)
         B.Nom_Base:=sb.Nom_Base;     -- on récup le nom de la base
         B.taille:=sb.taille;         -- la taille de ce nom

         for i in 1..sb.nb loop
            ajout_fin(B.Contenu_Base,sb.Contenu_Base(i).Nom_Table,sb.Contenu_Base(i).taille,NULL);    -- on parcourt le tableau des tables, et on les ajoute a notre liste de table
            act:=B.Contenu_Base;            -- pointeur sur liste de table
            compteur := 1 ;
            while(compteur/=i) loop        -- boucle permettant de pointer sur la bonne table avant d'y ajouter les attributs
               act := act.next;
               compteur := compteur+1;
            end loop;

            for j in 1..sb.Contenu_Base(i).nb loop    -- parcourt le tableau des attributs en les ajoutant a la liste, dans la bonne table
               ajout_fin(act.Contenu_Table,sb.Contenu_Base(i).Contenu_Table(j).Nom_Attribut,sb.Contenu_Base(i).Contenu_Table(j).taille, sb.Contenu_Base(i).Contenu_Table(j).type_attribut, sb.Contenu_Base(i).Contenu_Table(j).Carac_Attribut, NULL);
               compt := 1 ;
               aa:=act.Contenu_Table; -- pointeur sur liste d'attributs

               while(compt/=j) loop -- boucle permettant de pointeur sur le bon attribut avant d'y ajouter les données
                  aa := aa.Next ;
                  compt := compt+1;
               end loop;

               for k in 1..sb.Contenu_Base(i).Contenu_Table(j).nb loop      -- parcourt le tableau de données et les ajoute a la liste des données, dans le bon attribut
                  case sb.Contenu_Base(i).Contenu_Table(j).type_attribut is      -- comme les données sont mutantes, l'ajout dans la liste dépend du type de l'attribut
                     when P_sgbd.I => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).entier);
                     when P_sgbd.F => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).reel);
                     when P_sgbd.S => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).chaine,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).taille);
                     when P_sgbd.B => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).booleen);
                     when P_sgbd.C => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).carac);
                     when P_sgbd.D => ajout_fin(aa.Contenu_Attribut,sb.Contenu_Base(i).Contenu_Table(j).Contenu_Attribut(k).date);
                  end case;

               end loop;


            end loop;

         end loop;

         close(Fic);    -- on ferme le fichier en fin de procédure
      end open_base;



   -- ===================================================== save_base ==========================================================================
   -- Réalisé par Denis et Arnaud

      procedure save_base(Ba:in T_Base; nom_fic:in string; taille:integer) is
         st:savetable;
         base:T_base:=Ba;
         compt:integer:=0;
         tables: access_table;
         attributs:access_attribut;
         donnees: access_donnees;
         p:integer:=1;
         j:integer:=1;
         k:integer:=1;
         sb:T_saveBase;

      begin
         open(file=>fic,mode=>P_fichier.out_file,name=>nom_fic(nom_fic'first..taille));   -- ou ouvre le fichier qui va stocker la base
         tables:=base.Contenu_Base;     -- pointeur sur la liste de table
         if (tables/=NULL) then        -- si il y a des tables, "attributs" pointe sur liste d'attributs de la premiere table
            attributs:=base.contenu_base.Contenu_Table;
         end if;
         if(attributs/=NULL) then       -- si il y a des n-uplets, "donnees" pointe sur liste de données du premier attribut
            donnees:=base.Contenu_Base.Contenu_Table.Contenu_Attribut;
         end if;

      -- Pour toutes les opérations qui suivent, on "transfert" toutes nos listes dans des tableaux (mêmes structures que les listes mais avec tableaux).
      -- Car il est plus aisé de stocker des tableaux dans un fichier séquentiel.

         while(tables/=NULL)loop        -- boucle qui parcourt la liste des tables
            st(k).Nom_Table:=tables.all.Nom_Table;  -- stocke le nom & taille (du nom) des tables
            st(k).taille:=tables.all.taille;
         sb.nb := k;                  -- k est le compteur qui nous permet de stocker chaque table au bon endroit dans le tableau,
         			      -- il nous permet aussi de savoir combien il y a de tables au total, c'est pour cela qu'il est stocker dans le tableau

            while(attributs/=NULL)loop  -- boucle qui parcourt la liste des attributs
               st(k).Contenu_Table(j).Nom_Attribut:=attributs.all.Nom_Attribut;     -- on affecte touts les champs
               st(k).Contenu_Table(j).taille:=attributs.all.taille;
               st(k).Contenu_Table(j).type_attribut:=attributs.all.type_attribut;
               st(k).Contenu_Table(j).Carac_Attribut:=attributs.all.Carac_Attribut;
               st(k).nb := j;         -- j est le compteur qui nous permet de stocker chaque attribut au bon endroit dans le tableau,
         			      -- il nous permet aussi de savoir combien il y a d'attributs au total, c'est pour cela qu'il est stocker dans le tableau

               while(donnees/=NULL)loop  -- boucle qui parcourt la liste des données
               case attributs.type_attribut is     -- données est de type mutant, l'affectation dépends donc du type de l'attribut qu'on parcourt
                     -- affectation par nomination en n'oubliant pas le paramètre permettant de "muté" : type_donnees
                     when P_sgbd.I => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => I, entier => donnees.all.entier);
                     when P_sgbd.F => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => F, reel => donnees.all.reel);
                     when P_sgbd.S => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => S, chaine => donnees.all.chaine, taille => donnees.all.taille);
                     when P_sgbd.C => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => C, carac => donnees.all.carac);
                     when P_sgbd.B => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => B, booleen => donnees.all.booleen);
                     when P_sgbd.D => st(k).Contenu_Table(j).Contenu_Attribut(p) := (type_donnees => D, date => donnees.all.date);

                  end case;
                  st(k).Contenu_Table(j).nb := p ;  -- p est le compteur qui nous permet de stocker chaque données au bon endroit dans le tableau,
         			                    -- il nous permet aussi de savoir combien il y a de données (n-uplets) au total, c'est pour cela qu'il est stocker dans le tableau
                  p:=p+1;    -- incrémente le compteur pour passer au n-uplet suivant
                  donnees:=donnees.Next;    -- on pointe sur le n-uplet suivant
               end loop;

               p:=1;    -- on remet le compteur de n-uplet à 1 avant de passer a l'attribut suivant
               attributs:=attributs.Next;  -- on pointe sur l'attribut suivant
               j:=j+1;           -- incrémente le compteur pour passer à l'attribut suivant

               if attributs/=NULL then   -- si on est pas en fin de liste d'attribut, on fait pointé "donnees" sur la nouvelle liste de données
                  donnees:=attributs.Contenu_Attribut;
               end if;

            end loop;
            p:=1; -- on change de table, donc on remet les compteur d'attributs & de données à 1
            j:=1;
            tables:=tables.Next;   -- on pointe sur la table suivante
            if tables/=NULL then   -- on réaffecte nos pointeurs "attributs" et "donnees" a la bonne table
               attributs:=tables.Contenu_Table;
               if attributs/=NULL then
                  donnees:=tables.Contenu_Table.Contenu_Attribut;
               end if;
            end if;
            k:=k+1; -- on incrémente le compteur de table
         end loop;

         sb.Nom_base:=base.Nom_Base;  -- on sauvegarde le nom de la base
         sb.taille:=base.taille;      -- la taille de ce nom
         sb.Contenu_Base:=st;         -- & on affecte la structure de travail contenant toute la base sous forme de tableau à celle qu'on va sauvegarder

         write(Fic,sb);    -- puis on écrit dans le fichier la structure possédant toute la base sous forme de tableaux
         put_line("--> SAUVEGARDE DE LA BASE EFFECTUEE");

         close(Fic);    -- on ferme le fichier

      end save_base;


   -- ===================================================== del_base ==========================================================================
   -- Réalisé par Denis et Arnaud

      procedure del_base(nom_fic:string; taille:integer; close:in out boolean) is
         char : character;
      begin
         loop
            begin
               Put_line("Voulez vous vraiment supprimer votre base ? (y/n)");
               put("==>");
               Get(char);
               MAJ_char(char);   -- converti le caractère en majuscule pour éviter la casse
               case char is    -- si oui, on ouvre le fichier correspondant a la base puis on le supprime. et on passe le boolean a TRUE pour sortir du programme.
                  when 'Y' => open(file=>fic,mode=>P_fichier.out_file,name=>nom_fic(nom_fic'first..taille)); delete(fic); Put_line("Base supprimee, fin du programme"); close:=true;
                  when 'N' => NULL;   -- si non, on ne fait rien --> retourne au menu d'actions
                  when others => raise simple_IO.Data_error;
               end case;
               exit;
               exception
                  when simple_IO.data_error => put_line("Saisie incorrecte");
            end;
         end loop;


      end del_base;



   -- ===============================================================================================================================================
   -- ============================================== fonctions annexes sur les listes ===============================================================
   -- ===============================================================================================================================================


   -- ===================================================== liste_vide TABLE =======================================================================
   -- Réalisé par Arnaud et Helene

      function Liste_Vide (F:access_table) return boolean is
      begin
         return	F=NULL;
      end Liste_Vide;

   -- ===================================================== liste vide ATTRIBUTS ===================================================================
   -- Réalisé par Arnaud et Helene

      function Liste_Vide (F:access_attribut) return boolean is
      begin
         return F=NULL;
      end Liste_Vide;

   -- ===================================================== liste vide DONNEES =====================================================================
   -- Réalisé par Arnaud et Helene

      function Liste_Vide(F:access_donnees) return boolean is
      begin
         return F=NULL;
      end Liste_Vide;

   -- ===================================================== queue TABLES ============================================================================
   -- Réalisé par Arnaud et Helene

      function Queue (F:access_table) return access_table is
         tmp:access_table:=F;
      begin
         While(tmp.all.Next/=NULL) loop
            tmp:=tmp.all.Next;
         end loop;
         return tmp;
      end Queue;

   -- ===================================================== queue ATTRIBUTS =========================================================================
   -- Réalisé par Arnaud et Helene

      function Queue(F:access_attribut) return access_attribut is
      begin

         if (F.all.next=NULL) then
            return F;
         else
            return Queue(F.all.next);
         end if;
      end Queue;

   -- ===================================================== queue DONNEES ===========================================================================
   -- Réalisé par Arnaud et Helene

      function Queue(F:access_donnees) return access_donnees is
      begin
         if (F.all.next=NULL) then
            return F;
         else
            return Queue(F.all.Next);
         end if;
      end Queue;

   -- ================================================= nombre d'elements TABLE =====================================================================
   -- Réalisé par Arnaud et Helene

      function nb_elem(liste_tab:in access_table) return integer is
         i : integer := 0;
         liste:access_table:=liste_tab;
      begin
         while (liste/=NULL) loop
            liste:=liste.next;
            i:=i+1;
         end loop;
         return i;
      end nb_elem;

   -- =============================================== nombre d'elements ATRIBUTS ====================================================================
   -- Réalisé par Arnaud et Helene

      function nb_elem(liste_att:in access_attribut) return integer is
         i : integer := 0;
         liste:access_attribut:=liste_att;
      begin
         while (liste/=NULL) loop
            liste:=liste.next;
            i:=i+1;
         end loop;
         return i;
      end nb_elem;

   -- ================================================= nombre d'elements DONNEES ===================================================================
   -- Réalisé par Arnaud et Helene

      function nb_elem(liste_do:in access_donnees) return integer is
         i : integer := 0;
         liste:access_donnees:=liste_do;
      begin
         while (liste/=NULL) loop
            liste:=liste.next;
            i:=i+1;
         end loop;
         return i;
      end nb_elem;

   -- ===============================================================================================================================================
   -- ======================================= fonctions Ajout_fin table/attribut/chaque type donnees ================================================
   -- ===============================================================================================================================================

   -- ======================================================= ajout_fin TABLE =======================================================================
   -- Réalisé par Arnaud et Helene

      procedure Ajout_fin(F:in out access_table; nom:T_string; taille : integer ; contenu : Access_Attribut) is
         C: access_table;
         Dernier : access_table;
      begin
         C:=new T_Table'(nom,taille,contenu,NULL);
         if Liste_Vide(F) then
            F:=C;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ===================================================== ajout_en_tete ATTRIBUT =======================================================================
   -- Réalisé par Arnaud et Helene

      procedure Ajout_en_tete(F:in out access_attribut; nom:T_string; taille : integer ; type_attribut: T_enum ; cle : T_Cle; contenu : Access_Donnees) is
         C: access_attribut;
      begin
         C:=new T_Attribut'(nom,taille,type_attribut,cle,contenu,NULL);
         C.all.Next:=F;
         F:=C;
   end ajout_en_tete;

   -- ===================================================== ajout_fin ATTRIBUT =======================================================================
   -- Réalisé par Arnaud et Helene

      procedure Ajout_fin(F:in out access_attribut; nom:T_string; taille : integer ; type_attribut: T_enum ; cle : T_Cle; contenu : Access_Donnees) is
         C: access_attribut;
         Dernier : access_attribut;
      begin
         C:=new T_Attribut'(nom,taille,type_attribut,cle,contenu,NULL);
         if Liste_Vide(F) then
            F:=C;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ======================================================= ajout_fin DONNEES ======================================================================
   -- Réalisés par Denis et Valentin

   -- ******************ENTIER******************

      procedure Ajout_fin(F:in out access_donnees; donnees:Integer) is
         C: access_donnees;
         Dernier : access_donnees;
      begin
         C:=new T_donnees'(type_donnees=>I,next=>NULL,entier=>donnees);
         if Liste_Vide(F) then
            F:=C;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ******************REEL******************

      procedure Ajout_fin(Fi:in out access_donnees; donnees:float) is
         C: access_donnees;
         Dernier : access_donnees;
      begin
         C:=new T_donnees'(type_donnees=>F,next=>NULL,reel=>donnees);
         if Liste_Vide(Fi) then
            Fi:=C;
         else
            Dernier :=Queue(Fi);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ******************CARACTERE******************

      procedure Ajout_fin(F:in out access_donnees; donnees:character) is
         Ca: access_donnees;
         Dernier : access_donnees;
      begin
         Ca:=new T_donnees'(type_donnees=>C,next=>NULL,carac=>donnees);
         if Liste_Vide(F) then
            F:=Ca;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=Ca;

         end if;
      end Ajout_fin;

   -- ******************CHAINE******************

      procedure Ajout_fin(F:in out access_donnees; donnees:T_string; taille:integer) is
         C: access_donnees;
         Dernier : access_donnees;
      begin
         C:=new T_donnees'(type_donnees=>S,next=>NULL,chaine=>donnees, taille=>taille);
         if Liste_Vide(F) then
            F:=C;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ******************BOOLEEN******************

      procedure Ajout_fin(F:in out access_donnees; donnees:boolean) is
         C: access_donnees;
         Dernier : access_donnees;
      begin
         C:=new T_donnees'(type_donnees=>B,next=>NULL,booleen=>donnees);
         if Liste_Vide(F) then
            F:=C;
         else
            Dernier :=Queue(F);
            Dernier.all.Next:=C;

         end if;
      end Ajout_fin;

   -- ******************T_DATE******************

      procedure ajout_fin(F:in out access_donnees; donnees:T_date) is
         C:access_donnees;
         Dernier:Access_donnees;
      begin
         C:=new T_donnees'(type_donnees=>D, next=>NULL, date=>donnees);
         if liste_vide(F) then
            F:=C;
         else
            dernier:=Queue(F);
            dernier.all.next:=C;
         end if;
      end ajout_fin;


   -- ===============================================================================================================================================
   -- ================================================== fonctions de suppression ===================================================================
   -- ===============================================================================================================================================

   -- ======================================================= supprimer TABLE =======================================================================
   -- Réalisé par Arnaud et Denis

      procedure Supprimer (table: in out access_table) is
         tmp,freeteur:access_table;
         compt,k:integer:=1;
         S,nom:T_string;
         nb_tab,taille,L:integer;
         num_tab:integer:=0;
         sup:integer:=-1;

      begin
      affiche_table(table);
      nb_tab:=nb_elem(table);

      if(nb_tab>0) then		-- si il y a des tables
         loop
            begin
               while(sup<0 or sup>nb_tab)loop    -- boucle de controle de saisie
                  put_line("Combien de tables voulez vous supprimer?");
                  put("==>");
                  get(sup);
               end loop;
               exit;
            exception
            when others => put_line("Saisie incorrecte"); get_line(S,L);
            end;
         end loop;


         if(sup>0) then
            for i in 1..sup loop    -- boucle autant de fois que demandé
               loop
                  begin
                     nb_tab:=nb_elem(table);	-- on recalcule le nb de table a chaque boucle car il y a suppression
                     while(num_tab<1 or num_tab>nb_tab)loop     -- boucle de controle de saisie
                        put_line("Selectionner la table a supprimer");
                        put("==>");
                        get(num_tab);
                     end loop;

                     case num_tab is        -- deux cas possibles : suppression du 1er élement OU les autres
                     when 1 =>
                        freeteur := table;	-- pointeur temporaire sur le 1er element
                        table := table.Next;    -- pointeur table pointe sur le 2eme element
                        taille:=freeteur.taille;	-- on garde le nom et la taille du nom pour afficher message de validation plus tard
                        nom(1..taille):=freeteur.Nom_Table(1..freeteur.taille);
                        free_tab(freeteur);	-- on libère la mémoire du 1er element

                     when others =>
                        k:=1;		-- remet k à 1 a chaque boucle
                        freeteur := table;  -- freeteur pointe sur 1er element
                        while(k/=num_tab)loop		-- on boucle pour arriver à la bonne table
                           tmp:=freeteur;		-- on sauvegarde l'adresse de l'element precedent
                           freeteur:=freeteur.next;
                           k:=k+1;
                        end loop;
                        tmp.Next := freeteur.next;	-- on relie l'element précedent a l'element suivant
                        taille:=freeteur.taille;	-- on garde le nom et la taille du nom pour afficher message de validation plus tard
                        nom(1..taille):=freeteur.Nom_Table(1..freeteur.taille);
                        free_tab(freeteur);		-- on libère la mémoire de l'element voulu
                     end case;
                     num_tab:=-1;	-- on remet num_tab a une valeure neutre pour rentrer dans la boucle de controle de saisie

                  exit;
                  exception
                    when others => put_line("Saisie incorrecte"); get_line(S,L);
               end;
            end loop;

            put_line("LA TABLE " & nom(1..taille) & " a ete supprimee");
            new_line;

            affiche_table(table);


         end loop;
         end if;
      end if;


      end supprimer;

   -- =================================================== supprimer ATTRIBUTS =======================================================================
   -- Réalisé par Arnaud et Denis

      procedure Supprimer (liste_tab:access_table; table_cible:in out access_table) is
         tmp:access_attribut:=table_cible.contenu_table;
         freeteur:access_attribut;
         compt,k:integer:=1;
         S,nom:T_string;
         L,taille,nb_att:integer;
         num_att:integer:=0;
         sup:integer:=-1;

   begin
      affiche_attribut(liste_tab,table_cible);
      nb_att:=nb_elem(table_cible.contenu_table);

      if(nb_att>1) then		-- vérifie si il y a des attributs
         loop			-- boucle de controle de saisie
            begin
               while(sup<0 or sup>nb_att)loop		-- boucle de controle de saisie
                  put_line("Combien d'attributs voulez vous supprimer?");
                  put("==>");
                  get(sup);
               end loop;
               exit;
               exception
                  when others => put_line("Saisie incorrecte"); get_line(S,L);
            end;
         end loop;

         if(sup>0) then		-- si il veut supprimer au moins 1 attribut
            for i in 1..sup loop	-- boucle autant de fois que choisi
               loop			-- boucle de controle de saisie
                  begin
                     nb_att:=nb_elem(table_cible.contenu_table);
                     while(num_att<1 or num_att>nb_att)loop		-- boucle de controle de saisie
                        put_line("Selectionner l'attribut a supprimer");
                        put("==>");
                        get(num_att);
                     end loop;
                     exit;
                  exception
                     when others => Put_line("Saisie incorrecte !"); get_line(S,L);
                  end;
               end loop;

               case num_att is		 -- deux cas possibles : suppression du 1er élement OU les autres
                     when 1 =>
                        freeteur := table_cible.Contenu_Table;		-- pointeur temporaire sur le 1er element
                        table_cible.Contenu_Table :=table_cible.Contenu_Table.Next;		-- pointeur table_cible pointe sur le 2eme element
                        taille:=freeteur.taille;		-- on garde le nom et la taille du nom pour afficher message de validation plus tard
                        nom(1..taille):=freeteur.nom_attribut(1..freeteur.taille);
                        free_at(freeteur);		-- on libère la mémoire du 1er element

                  when others =>
                     k:=1;     	-- remet k à 1 à chaque boucle
                     freeteur := table_cible.Contenu_Table;	-- freeteur pointe sur 1er element
                     while(k/=num_att)loop		-- on boucle pour arriver à la bonne table
                        tmp:=freeteur;			-- on sauvegarde l'adresse de l'element precedent
                        freeteur:=freeteur.next;
                        k:=k+1;
                     end loop;
                     tmp.Next := freeteur.next;		-- on relie l'element précedent a l'element suivant
                     taille:=freeteur.taille;		-- on garde le nom et la taille du nom pour afficher message de validation plus tard
                     nom(1..taille):=freeteur.nom_attribut(1..freeteur.taille);
                     free_at(freeteur);		-- on libère la mémoire de l'element voulu
               end case;

               num_att:=0;           -- on remet num_att a une valeure neutre pour rentrer dans la boucle de controle de saisie
               new_line;
               put_line("L'ATTRIBUT " & nom(1..taille) & " a ete supprime");
               new_line;
               affiche_attribut(liste_tab,table_cible);
            end loop;
         end if;
      end if;
      end supprimer;

   -- =================================================== supprimer DONNEES ==========================================================================
   -- Réalisé par Arnaud et Denis

   procedure Supprimer_donnees(liste:access_table; table_cible:in out access_table) is
      nb,nb_del:integer:=-1;
      attribut:access_attribut;
      donnees,new_donnees,freeteur:access_donnees;
      compt:integer:=1;
      L,nb_nupl:integer;
      S:string(1..80);

      begin

      affiche_donnees(liste,table_cible);		-- affiche les donnees
      nb_nupl:=nb_elem(table_cible.Contenu_Table.Contenu_Attribut);		-- calcule le nb de n-uplets

      if(nb_nupl>0) then 		-- si il y a des n-uplets
         loop		-- boucle de controle de saisie
            begin
               while(nb_del<0 or nb_del>nb_nupl) loop		-- boucle de controle de saisie
                  Put_line("Combien de n-uplet voulez-vous supprimer ?");
                  get(nb_del);
               end loop;
               exit;
               exception
                  when others => get_line(S,L); Put_line("Saisie incorrecte");
            end;
         end loop;

         if(nb_del>0) then 		-- si il veut supprimer au moins 1 n-uplet
            for p in 1..nb_del loop	-- on boucle autant de fois que voulu
               nb:=-1;			-- on remet nb à -1 pour rentrer dans la boucle de controle de saisie
               loop
                  begin
                     while(nb<0 or nb>nb_nupl) loop		-- boucle de controle de saisie
                        Put_line("Quel n-uplet voulez-vous supprimer ?");
                        get(nb);
                     end loop;
                     exit;
                  exception
                     when others => get_line(S,L); Put_line("Saisie incorrecte");
                  end;
               end loop;

               attribut:=table_cible.Contenu_Table;	-- pointeur sur la liste d'attributs

               while(attribut/=NULL) loop		-- parcourt la liste d'attributs
                  donnees := attribut.Contenu_Attribut;		-- pointeur temporaire sur la liste de donnees de l'attribut parcouru
                  compt:=1;
                  while(donnees/=NULL)loop		-- parcourt la liste de données
                     if (compt/=nb) then		-- si on est pas sur l'element à supprimer, on le rajoute a nouvelle liste de données
                        case attribut.type_attribut is		-- les donnees sont de plusieurs type, depend du type attribut
                        when P_sgbd.I => ajout_fin(new_donnees,donnees.entier);
                        when P_sgbd.F => ajout_fin(new_donnees,donnees.reel);
                        when P_sgbd.C => ajout_fin(new_donnees,donnees.carac);
                        when P_sgbd.S => ajout_fin(new_donnees,donnees.chaine, donnees.taille);
                        when P_sgbd.B => ajout_fin(new_donnees,donnees.booleen);
                        when P_sgbd.D => ajout_fin(new_donnees,donnees.date);
                        end case;
                     end if;
                     compt := compt+1;	-- incrémente le compteur
                     freeteur:=donnees;	-- on sauvegarde l'adresse de l'element precedent
                     donnees:=donnees.Next; -- on passe au suivant
                     free_do(freeteur);		-- libère la mémoire de l'element precedent
                  end loop;
                  attribut.Contenu_Attribut:=new_donnees; 	-- relie la liste de la base a la nouvelle liste de données
                  new_donnees:=NULL;		-- on remet le pointeur a NULL pour s'en resservir a la prochaine boucle
                  attribut:=attribut.Next;	-- on passe a l'attribut suivant
               end loop;

               affiche_donnees(liste,table_cible);	-- affiche les donnees
               Put_line("--> Le n-uplet numero " & integer'image(nb) & " a ete correctement supprime !");
            end loop;
         else
            Put_line("Aucun n-uplet n'a ete supprime !");
         end if;

      end if;
      new_line;

   end Supprimer_donnees;



   -- ===============================================================================================================================================
   -- ================================================== fonctions d'affichage ======================================================================
   -- ===============================================================================================================================================

   -- ======================================================== afficher TABLE =======================================================================
   -- Réalisé par Arnaud et Helene

   procedure affiche_table(liste_table : access_table) is
      tmp : access_table:=liste_table;
      i : integer:=1;
   begin
      if(tmp=NULL) then	-- message d'erreur si il n'y a pas de table a afficher
         put_line("WARNING - Base vide");
      end if;

      while(tmp/=NULL) loop	-- si il y a des tables alors on les affiches
         Put_line(Integer'Image(i) & " : " & tmp.all.Nom_Table(1..tmp.all.taille));
         i:=i+1;
         tmp:=tmp.all.Next;	-- passe a l'element suivant
      end loop;
      new_line;
   end affiche_table;

   -- ======================================================= affiche ATTRIBUTS =====================================================================
   -- Réalisé par Arnaud et Helene

   procedure affiche_attribut(liste_table :access_table; table_cible:in out access_table) is
      S:T_String;
      L:integer;
      compteur,i:integer:=1;
      liste_attribut:access_attribut;
      num:integer:=0;
      nb_tab:integer:=nb_elem(liste_table);
   begin

      if(table_cible=NULL) then		-- si une table n'est pas déjà choisie, on demande une saisie
         affiche_table(liste_table);

         if (liste_table/=NULL) then	-- si il y a des tables
            table_cible:=liste_table;	-- table_ciblle pointe sur le 1er element
            loop		-- boucle de saisie controlee
               begin
                  while(num<1 or num>nb_tab)loop	-- boucle de saisie controlee
                     put_line("Selectionnez une table a afficher");
                     put("==>");
                     get(num);
                  end loop;
                  exit;
               exception
                  when others=> put_line("Saisie incorrecte"); get_line(S,L);
               end;
            end loop;

            while(compteur/=num) loop	-- boucle qui permet a table_cible de pointer sur la table choisie
               table_cible:=table_cible.all.next;
               compteur:=compteur+1;
            end loop;
            new_line;
         end if;
      end if;

      if (table_cible/=NULL) then	-- si une table est choisie, on fait pointer liste_attribut sur la liste des attributs
         liste_attribut:=table_cible.Contenu_Table;
      end if;

      if(table_cible/=NULL and liste_attribut=NULL) then	-- si il n'y a pas encore d'attribut : message d'information
         put_line("WARNING - TABLE VIDE"); new_line;
      end if;

      while(liste_attribut/=NULL) loop		-- si il y a des attributs, on parcourt la liste et on les affiche
         Put(integer'image(i) & " : " & liste_attribut.all.Nom_Attribut(1..liste_attribut.all.taille));
         if(liste_attribut.all.carac_attribut/=n) then
            put(" - " & T_Cle'image(liste_attribut.all.carac_attribut));
         end if;

         put_line("   (" & T_enum'image(liste_attribut.type_attribut) & ")");
         i:=i+1;
         liste_attribut:=liste_attribut.all.Next;
      end loop;
      new_line;
   end affiche_attribut;

   -- ======================================================== affiche DONNEES ======================================================================
   -- Réalisé par Denis et Valentin

   procedure affiche_donnees(liste_table :access_table; table_cible: in out access_table) is
      S:T_String;
      ch:T_string:=(others=>' ');
      compteur,lig,col,compteur_at:integer:=1;
      compt,num:integer:=0;
      L,nb_attribut,nb_table,nb_nupl,tab_plein,tab_rest: integer;
      real:float;
      liste_attribut_tmp,tmp_attribut : access_attribut;
      liste_donnees:access_donnees;
      type tab is array (integer range <>, integer range <>) of T_string;

   begin

      if (liste_table/=NULL) then		-- si il y a des tables
         if(table_cible=NULL)then		-- si la table à afficher n'est pas encore choisie
            nb_table:=nb_elem(liste_table);   	-- calcule le nombre de table
            affiche_table(liste_table);		-- affiche liste des tables
            table_cible:=liste_table;		-- table_cible pointe sur le 1er element de la liste des tables
            loop		-- boucle de saisie controlee
               begin
                  while(num<1 or num>nb_table) loop		-- boucle de saisie controlee
                     put_line("Selectionnez une table :");
                     put("==>");
                     get(num);
                  end loop;
                  exit;
               exception
                  when others=> put_line("Saisie incorrecte"); get_line(S,L);
               end;
            end loop;

            while(compteur/=num) loop		-- boucle qui permet de faire pointer table_cible sur la table choisie par l'utilisateur
               table_cible:=table_cible.all.next;
               compteur:=compteur+1;
            end loop;
         end if;

         if(table_cible.Contenu_Table/=NULL) then	-- si il y a des attributs
            if (table_cible.Contenu_Table.Contenu_Attribut/=NULL) then	-- si il y a des n-uplets

               nb_attribut := nb_elem(table_cible.Contenu_Table);		-- calcule le nombre d'attribut
               nb_nupl := nb_elem(table_cible.Contenu_Table.Contenu_Attribut);	-- calcule le nombre de n-uplets
               liste_attribut_tmp:=table_cible.Contenu_Table;			-- pointeur sur liste d'attribut

               DECLARE
                  tableau:tab(1..nb_nupl+1,1..nb_attribut):=(OTHERS=>(OTHERS=>"                   "));		-- on connait les dimensions du tableau, on peut le contraindre
               begin

                  -- REMPLISSAGE DU TABLEAU

                  for j in 1..nb_attribut loop		-- on remplit la premiere ligne du tableau par les noms des attributs en parcourant la liste des attributs
                     tableau(1,j) := liste_attribut_tmp.Nom_Attribut ;
                     liste_attribut_tmp:=liste_attribut_tmp.Next;
                  end loop;

                  liste_attribut_tmp:=table_cible.Contenu_Table;	-- on refait pointer liste_attribut_tmp sur le 1er attribut

                  for I in 1..nb_attribut loop -- colonnes
                     liste_donnees:=liste_attribut_tmp.Contenu_Attribut;	-- pointeur liste_donnees sur le 1er element des donnees de l'attribut parcouru

                     for J in 2..nb_elem(liste_donnees)+1 loop -- lignes	-- +1 car la premiere ligne contient le nom des attributs

                        case liste_attribut_tmp.type_attribut is	-- en fonction du type de l'attribut on effectue la bonne opération

                           when P_sgbd.I => -- INTEGER
                              declare
                                 ch:string:=Integer'Image(liste_donnees.entier);	-- variable string temporaire contenant l'entier après conversion
                              begin
                                 tableau(j,i)(1..ch'Length):=ch;	-- on affecte l'entier dans la case du tableau, dans les bonnes tranches de string
                              end;

                           when P_sgbd.F => -- FLOAT
                              declare
                                 ch:string:= Float'Image(liste_donnees.reel);		-- variable string temporaire contenant le float après conversion
                              begin
                                 tableau(j,i)(1..ch'length):=ch;	-- on affecte le float dans la case du tableau, dans les bonnes tranches de string
                              end;

                           when P_sgbd.S => -- STRING
                              tableau(J,I)(1..liste_donnees.taille) := liste_donnees.chaine(1..liste_donnees.taille); -- aucune conversion necessaire

                           when P_sgbd.C =>  -- CHARACTER
                              tableau(J,I)(1) := liste_donnees.carac;	-- aucune conversion necessaire

                           when P_sgbd.B => -- BOOLEAN
                              declare
                                 ch:string:=Boolean'Image(liste_donnees.booleen);	-- variable string temporaire contenant le boolean après conversion
                              begin
                                 tableau(J,I)(1..ch'length):=ch;	-- on affecte le boolean dans la case du tableau, dans les bonnes tranches de string
                              end;

                           when D => Ecrire(liste_donnees.date,ch);	-- on se sert de la fonction écrire du paquetage P_Date pour passer la date en String
                              tableau(J,I) := ch;
                        end case;
                        liste_donnees:=liste_donnees.Next;	-- on passe au n-uplet suivant
                     end loop;
                     liste_attribut_tmp:=liste_attribut_tmp.Next;	-- passe a l'attribut suivant
                  end loop;

                  Put("                              -- "); Put(table_cible.Nom_Table(1..table_cible.taille)); Put(" --"); -- affiche le nom de la table en haut du tableau
                  new_line;

                  ---------------------------------***  AFFICHAGE DES TABLEAUX ***----------------------------------------

                  tab_plein:=nb_attribut / 3;		-- calcul du nombre de tableaux plein à afficher : maximum 3 attribut par tableau (raison de lisibilité dans console Windows)
                  tab_rest:=nb_attribut rem 3;		-- calcul du nombre d'attributs restant à afficher dans le dernier tableau

                  ---------------------------------- AFFICHAGE DES TABLEAUX PLEINS  ------------------------------------

                  lig:=1; col:=1;
                  for w in 1..tab_plein loop
                     col:=w*3-2;
                     lig:=1;
                     for I in 1..3 loop
                        if i=1 then
                           Put("    --------------------");
                        else
                           Put("--------------------");
                        end if;
                     end loop;

                     new_line;
                     while(lig <= nb_nupl+1) loop
                        while(col <= w*3) loop
                           if (col=w*3-2 and lig=1) then
                              put("   |");
                           end if;

                           if ((col=w*3-2) and (lig>1)) then
                              Put(compt,2); Put(" |");
                           end if;

                           compteur_at:=1;
                           tmp_attribut:=table_cible.Contenu_Table;

                           while(col/=compteur_at and lig>1)loop		-- boucle permettant de pointer sur l'attribut qu'on affiche (colonne) : permet la gestion des float
                              tmp_attribut:=tmp_attribut.next;
                              compteur_at:=compteur_at+1;
                           end loop;

			-- GESTION DE L'AFFICHAGE DES FLOAT
                           if(tmp_attribut.type_attribut=F)then			-- si l'attribut qu'on affiche est un float
                              real:=float'value(tableau(lig,col));
                              put(real,16,2,0);					-- il faut gérer l'écriture scientifique du float et l'afficher normalement, donc ne pas passer par la variable string
                           else
                        -- AFFICHAGE DES AUTRES TYPES
                              Put(tableau(lig,col));
                           end if;
                           Put("|");
                           col:=col+1;
                        end loop;

                        col:=w*3-2;
                        compt:=compt+1;

                        if (lig=1 or lig=nb_nupl+1) then
                           new_line;
                           for K in 1..3 loop
                              if (lig=1 and k=1) then
                                 Put("   |--------------------");
                              elsif (lig=nb_nupl+1 and k=1) then
                                 Put("    --------------------");
                              else
                                 Put("--------------------");
                              end if;
                           end loop;
                        end if;
                        new_line;
                        lig:=lig+1;
                     end loop;
                     new_line; new_line;
                     compt:=0;
                  end loop;
                  compt:=0;
                  ------------------------------------  AFFICHAGE DU DERNIER TABLEAU  ------------------------------------

                  if tab_rest > 0 then
                     col:=tab_plein*3+1;
                     lig:=1;
                     for I in 1..tab_rest loop
                        if i=1 then
                           Put("    --------------------");
                        else
                           Put("--------------------");
                        end if;
                     end loop;

                     new_line;

                     while(lig <= nb_nupl+1) loop
                        while(col <= nb_attribut) loop
                           if (col=tab_plein*3+1 and lig=1) then
                              put("   |");
                           end if;

                           if ((col=tab_plein*3+1) and (lig>1)) then
                              Put(compt,2); Put(" |");
                           end if;

                           compteur_at:=1;
                           tmp_attribut:=table_cible.Contenu_Table;

                           while(col/=compteur_at and lig>1)loop		-- boucle permettant de pointer sur l'attribut qu'on affiche (colonne) : permet la gestion des float
                              tmp_attribut:=tmp_attribut.next;
                              compteur_at:=compteur_at+1;
                           end loop;

                           -- GESTION DE L'AFFICHAGE DES FLOAT
                           if(tmp_attribut.type_attribut=F)then			-- si l'attribut qu'on affiche est un float
                              real:=float'value(tableau(lig,col));
                              put(real,16,2,0);					-- il faut gérer l'écriture scientifique du float et l'afficher normalement, donc ne pas passer par la variable string
                           else
                           -- AFFICHAGE DES AUTRES TYPES
                              Put(tableau(lig,col));
                           end if;
                           Put("|");
                           col:=col+1;
                        end loop;

                        col:=tab_plein*3+1;
                        compt:=compt+1;

                        if (lig=1 or lig=nb_nupl+1) then
                           new_line;
                           for K in 1..tab_rest loop
                              if (lig=1 and k=1) then
                                 Put("   |--------------------");
                              elsif (lig=nb_nupl+1 and k=1) then
                                 Put("    --------------------");
                              else
                                 Put("--------------------");
                              end if;
                           end loop;
                        end if;
                        new_line;
                        lig:=lig+1;

                     end loop;
                     new_line; new_line;
                  end if;
               end;
            else
               put_line("WARNING - Aucun n-uplet");
            end if;
         else
            put_line("WARNING - Aucun attribut");
         end if;
      else
         put_line("WARNING - Aucune table");
      end if;
      new_line;

   end affiche_donnees;


   -- ===============================================================================================================================================
   -- ==================================================== fonctions d'edition ======================================================================
   -- ===============================================================================================================================================

   -- ========================================================== edition TABLE ======================================================================
   -- Réalisé par Arnaud et Helene

   procedure edit_table(liste: in out access_table) is
      nb:integer:=-1;
      S:T_string;
      L,taille:integer;
      nom:T_string:=(others=>' ');
      ch_tmp:T_dechet:=(others=>' ');

   begin
      put_line("-- MODE EDITION (creation de nouvelles tables) --");
      loop					-- boucle de saisie controlee
         begin
            while(nb<0 or nb>20) loop		-- boucle de saisie controlee
               put_line("Combien de tables voulez vous creer?");
               get(nb);
               end loop;
            exit;
         exception
            when others => put_line("Saisie incorrecte"); get_line(S,L);
         end;
      end loop;

      get_line(S,L);		-- vide le buffer car on vient de saisir un entier et ensuite il y a une saisie d'une chaine

      if(nb/=0)then		-- si il veut créer au moins une table
         for i in 1..nb loop	-- on boucle autant de fois que voulu
            taille:=0;		-- on remet la taille à 0 pour rentrer dans la boucle de saisie controlee
            while(taille<1 or taille>19) loop	-- boucle de saisie controlee : chaine maximum de 19 carac
               put_line("veuillez saisir le nom de la table" & integer'image(i));
               get_line(ch_tmp,taille);
               if(taille<1 or taille>19) then -- on affiche l'erreur si la chaine n'est pas correcte
                  Put_line("Chaine de taille incorrecte ! (1 a 19)"); new_line;
               end if;
            end loop;
            nom(1..taille):= ch_tmp(1..taille);		-- on affecte a la bonne variable la bonne tranche de string
            MAJ(nom, taille);				-- convertit le nom de la table en majuscule : c'est plus lisible
            ajout_fin(liste,nom,taille,NULL);		-- on ajoute la table a la liste
         end loop;
      end if;

      new_line;
      affiche_table(liste);		-- on affiche la nouvelle liste de table
   end edit_table;

   -- ======================================================== edition ATTRIBUT =====================================================================
   -- Réalisé par Arnaud et Helene

   procedure edit_attribut(Base:access_table; liste: in out access_table) is
      nb:integer:=-1;
      S,type_att,carac:T_string;
      nom:T_String:=(others=>' ');
      ch_tmp:T_dechet:=(others=>' ');
      carac_att:T_cle;
      L,long:integer;
      taille:integer:=0;
      type_att_enum:T_enum;

   begin
      put_line("MODE EDITION : table " & liste.all.Nom_Table(1..liste.all.taille) & " (creation de nouveaux attributs)");new_line;

      loop				-- boucle de controle de saisie
         begin
            while(nb<0 or nb>20) loop	-- boucle de controle de saisie
               put_line("Combien d'attributs voulez vous creer?");
               get(nb);
            end loop;
            exit;
         exception
            when others => put_line("Saisie incorrecte"); get_line(S,L);
         end;
      end loop;

      if(nb/=0)then 		-- s'il veut créer au moins 1 attribut
         for i in 1..nb loop	-- boucle autant de fois que nécessaire
            taille:=0;		-- remet la taille a 0 pour rentrer dans la boucle de controle de saisie
            while(taille<1 or taille>19) loop		-- boucle de controle de saisie
               put_line("veuillez saisir le nom de l'attribut" & integer'image(i));
               get_line(ch_tmp,taille);
               if(taille<1 or taille>19) then	-- affiche le message d'erreur
                  Put_line("Chaine de taille incorrecte ! (1 a 19)");
                  new_line;
               end if;
            end loop;

            nom(1..taille):=ch_tmp(1..taille);	-- on affecte le nom de l'attribut dans la bonne variable

            loop		-- boucle de controle de saisie
               begin
                  put_line("Saisir un type d'attribut (I,F,C,S,B,D)");
                  put("==>");
                  get_line(type_att,long);
                  type_att_enum:=T_enum'value(type_att(1..long));
                  exit;
               exception
                  when others => Put_line("Saisie incorrecte"); Get_line(S,L);
               end;
            end loop;

            loop		-- boucle de controle de saisie
               begin
                  put_line("Saisir 'cp' pour cle primaire ou 'ce' pour cle etrangere, 'n' sinon");
                  put("==>");
                  get_line(carac,long);
                  carac_att:=T_cle'value(carac(1..long));
                  exit;
               exception
                  when others=> put_line("Saisie incorrecte"); get_line(S,L);
               end;
            end loop;

            if(carac_att=cp) then	-- si l'attribut est une clé primaire, on l'ajoute en tete de liste des attributs pour + de lisibilité
               ajout_en_tete(liste.contenu_table,nom, taille, type_att_enum, carac_att, NULL);
            else
               ajout_fin(liste.contenu_table,nom, taille, type_att_enum, carac_att, NULL);
            end if;
         end loop;
      end if;

      affiche_attribut(Base,liste);	-- on affiche la nouvelle liste d'attribut
   end edit_attribut;

   -- ========================================================= edition DONNEES======================================================================
   -- Réalisé par Denis et Valentin

   procedure edit_donnees(liste_table: in out access_table) is
      nb,taille:integer:=0;
      S,bool_saisie,chaine:T_string;
      ch_tmp:T_dechet;
      table_cible:access_table:=liste_table;
      attribut:access_attribut;
      compteur:integer:=1;
      bool:boolean;
      nb_table:integer:=nb_elem(liste_table);
      L,entier:integer;
      reel:float;
      carac:character;
      nupl:integer:=-1;
      date:T_date;

   begin

      new_line;
      put_line("-- MODE EDITION : creation de nouvelles donnees --");new_line;
      affiche_table(liste_table);		-- affiche la liste des tables

      loop		-- boucle de saisie controlee
         begin
            while(nb<1 or nb>nb_table) loop	-- boucle de saisie controlee
               Put_line("Quelle table souhaitez vous remplir ?");
               get(nb);
            end loop;
            exit;
         exception
            when others=> put_line("Saisie incorrecte"); get_line(S,L);
         end;
      end loop;

      while(compteur/=nb)loop		-- boucle qui permet de faire pointer table_cible sur la table choisie
         table_cible:=table_cible.Next;
         compteur:=compteur+1;
      end loop;

      loop		-- boucle de saisie controlee
         begin
            while(nupl<0 or nupl>20) loop	-- boucle de saisie controlee
               put_line("Combien de n-uplets voulez vous creer ?");
               get(nupl);
            end loop;
            exit;
         exception
            when others => Put_line("Saisie incorrecte"); get_line(S,L);
         end;
      end loop;

      if(table_cible.Contenu_Table.type_attribut /= I or table_cible.Contenu_Table.type_attribut /= F) then
         get_line(S,L);		-- il faut vider le buffer si le premier attribut qu'on va remplir n'est pas un integer ou un float
      end if;


      if(nupl/=0)then		-- si il veut rentrer au moins 1 n-uplet

         for i in 1..nupl loop	-- on boucle autant de fois que nécessaire

            attribut:=table_cible.Contenu_Table; new_line;	-- fait pointer attribut sur le 1er attribut
            Put_line("## N-uplet numero " & integer'Image(i) & " ##");

            while(attribut/=NULL)loop		-- parcourt la liste des attributs
               case attribut.type_attribut is	-- la saisie et l'ajout de la donnée dépend du type de l'attribut : saisie par n-uplet, attribut après attribut
                  when P_sgbd.I =>
                     loop		-- boucle de saisie controlee
                        begin
                           Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : ");
                           Get(entier); get_line(S,L);
                           exit;
                        exception
                           when others => put_line ("Saisie incorrecte"); get_line(S,L);
                        end;
                     end loop;
                     ajout_fin(attribut.Contenu_Attribut,entier);	-- on ajoute l'entier a la liste des données de l'attribut

                     when P_sgbd.F =>
                        loop		-- boucle de saisie controlee
                           begin
                              Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : ");
                              Get(reel);  skip_line;
                              exit;
                              exception
                                 when others => put_line ("Saisie incorrecte"); get_line(S,L);
                           end;
                        end loop;
                        ajout_fin(attribut.Contenu_Attribut,reel);	-- on ajoute le reel a la liste des données de l'attribut

                  when P_sgbd.S =>
                     taille:=0;       -- on remet la taille a 0 pour rentrer dans la boucle de saisie controlee
                     while(taille<1 or taille>19)loop	-- boucle de saisie controlee
                        Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : ");
                        Get_line(ch_tmp,taille);
                        if(taille<1 or taille>19) then	-- affiche le message d'erreur
                           Put_line("Chaine de taille incorrecte ! (1 a 19)"); new_line;
                        end if;
                     end loop;
                     chaine(1..taille):=ch_tmp(1..taille);
                     ajout_fin(attribut.Contenu_Attribut,chaine,taille);	-- on ajoute la chaine a la liste des données de l'attribut

                  when P_sgbd.C =>
                     taille:=0;		-- on remet la taille a 0 pour rentrer dans la boucle de saisie controlee
                     loop		-- boucle de saisie controlee
                        begin
                           Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : ");
                           Text_IO.Get_Immediate(Carac);
                           maj_char(carac);
                           Put(carac); new_line;
                           exit;
                        exception
                           when others => put_line ("Saisie incorrecte"); get_line(S,L);
                        end;
                     end loop;
                     ajout_fin(attribut.Contenu_Attribut,carac);		-- on ajoute le caractère a la liste des données de l'attribut

                     when P_sgbd.B =>
                        loop		-- boucle de saisie controlee
                           begin
                           Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : "); Put_line("True / False");
                           Get_line(bool_saisie,taille);
                           bool:=Boolean'value(bool_saisie(1..taille));		-- on convertit la chaine en boolean
                           exit;
                              exception
                                 when others => put_line ("Saisie incorrecte"); new_line;
                           end;
                        end loop;
                           ajout_fin(attribut.Contenu_Attribut,bool);		-- on ajoute le boolean a la liste des données de l'attribut

                     when P_sgbd.D =>
                        Put(attribut.Nom_Attribut(1..attribut.taille) & " [" & T_Enum'Image(attribut.type_attribut) & "] : ");
                        Lire(date);	-- lit la date
                        ajout_fin(attribut.Contenu_Attribut,date);		-- on ajoute la date a la liste des données de l'attribut

               end case;
               attribut:=attribut.Next;		-- passe a l'attribut suivant
            end loop;
         end loop;
      end if;
      new_line;
      affiche_donnees(liste_table,table_cible);	-- affiche a nouveau la table avec le/les n-uplet(s) entrés

   end edit_donnees;


   -- ===============================================================================================================================================
   -- ============================================= fonctions de gestion dynamique de mémoire =======================================================
   -- ===============================================================================================================================================

   -- =============================================== vider la mémoire d'une TABLE ==================================================================
   -- Réalisé par Arnaud et Denis

   procedure free_tab(liste:in out access_table) is
   begin
      if liste.Contenu_Table /= NULL then	-- si il y a des attributs on détruit toute la liste des attributs
         detruire_liste_at(liste.contenu_table);
      end if;

      free_table(liste);	-- libère la mémoire allouée
   end free_tab;

   -- =============================================== vider la mémoire d'un ATTRIBUT ================================================================
   -- Réalisé par Arnaud et Denis

   procedure free_at(liste:in out access_attribut) is
   begin
      if liste.Contenu_Attribut /= NULL then	-- si il y a des données dans l'attribut on détruit toute la liste des données
         detruire_liste_do(liste.contenu_attribut);
      end if;

      free_attribut(liste);	-- libère la mémoire allouée
   end free_at;

   -- ================================================ vider la mémoire d'une DONNEE =================================================================
   -- Réalisé par Arnaud et Denis

   procedure free_do(liste:in out access_donnees) is
   begin
      free_donnees(liste);
   end free_do;

   -- ===================================== vider la mémoire d'une liste complete d'ATTRIBUTS ========================================================
   -- Réalisé par Arnaud et Denis

   procedure detruire_liste_at(liste:in out access_attribut) is
      tmp:access_attribut;
   begin
      while(liste /= NULL) loop		-- parcourt la liste des attributs
         tmp:=liste;			-- sauvegarde l'element precedent
         liste:=liste.Next;		-- passe a l'element suivant
         free_at(tmp);			-- libère la mémoire de l'attribut précédent
      end loop;

      end detruire_liste_at;

   -- ===================================== vider la mémoire d'une liste complete de DONNEES ========================================================
   -- Réalisé par Arnaud et Denis

   procedure detruire_liste_do(liste:in out access_donnees) is
      tmp:access_donnees;
   begin
      while(liste/=NULL)loop		-- parcourt la liste des donnees
         tmp:=liste;			-- sauvegarde l'element precedent
         liste:=liste.Next;		-- passe a l'element suivant
         free_do(tmp);			-- libère la mémoire de la donnée précédente
      end loop;
   end detruire_liste_do;

   -- ===============================================================================================================================================
   -- =================================================== fonctions annexes =========================================================================
   -- ===============================================================================================================================================

   -- ========================================= conversion d'une chaine en Majuscule ================================================================
   -- Réalisé par Arnaud et Helene

      procedure MAJ(nom:in out T_string; taille:in integer) is
      begin

         for i in 1..taille loop
            if (character'pos(nom(i))>96 and character'pos(nom(i)) < 123) then
               nom(i):=character'val(character'pos(nom(i))-32);
            end if;
         end loop;
      end MAJ;

   -- ========================================= conversion d'un caractere en Majuscule ==============================================================
   -- Réalisé par Arnaud et Helene

      procedure MAJ_char(char:in out character) is
      begin
         if (character'pos(char)>96 and character'pos(char) < 123) then
            char:=character'val(character'pos(char)-32);
         end if;
      end MAJ_char;


   ----------------------------------------------------------fin paquetage---------------------------------------------------------------------------
   end P_sgbd;
