-- ***********************************************************************
-- ************** PROJET ADA - IUT INFORMATIQUE METZ *********************
-- ******************  LEWIS Arnaud, MLUDEK Denis ************************
-- **************** STEYER Valentin, TERRIER Hélène* *********************
-- ************************ Annee 2011/2012 ******************************
-- ***********************************************************************

with Simple_IO,P_Sgbd, text_IO;
use Simple_IO,P_sgbd;

procedure Main is

   -- ====================================================================
   -- ================== Declaration des variables =======================
   -- ====================================================================

   F:File_type;
   char : character;
   Base:T_base;
   answer:character;
   nb,taille,num,j:integer:=1;
   table_cible:access_table;
   nom_fic:string(1..36);
   taille_fic:integer:=0;
   sortir:boolean:=false;
   close:boolean:=false;

   -- ====================================================================
   -- ================== Début du programme principal ====================
   -- ====================================================================
begin
   create_open(Base,nom_fic,taille_fic,sortir);		-- procedure permettant de créer ou d'ouvrir une base
   if not sortir then

      loop		-- boucle de saisie controlee
         begin
            new_line;
            put_line("-- CHOISIR UNE ACTION : --");
            put_line("T: Gestion des tables");
            put_line("A: Gestion des attributs");
            put_line("D: Gestion des donnees");
            put_line("E: Enregistrer la base courante");
            put_line("S: Supprimer la base courante");
            put_line("Q: Quitter le programme");
            text_IO.get_immediate(char);new_line;	-- get_immediate pour plus de confort
            MAJ_char(char);				-- conversion en majuscule pour éviter la casse

            case char is				-- gestion de la navigation dans le menu
               when 'T' => affiche_table(Base.Contenu_Base);new_line;
                  loop
                     begin
                        put_line("-- GESTION DES TABLES : --");
                        put_line("A: Ajouter une ou plusieurs table(s)");
                        put_line("S: Supprimer une ou plusieurs table(s)");
                        put_line("R: Retourner au menu principal");
                        text_IO.get_immediate(answer);
                        MAJ_char(answer);
                        new_line;
                        case answer is					-- navigation dans le sous menu
                           when 'A' => edit_table(Base.Contenu_Base);	-- procedure qui ajoute des tables
                           when 'S' => supprimer(Base.contenu_base);	-- procedure qui supprime une/des table(s)
                           when 'R' => exit;				-- revient au menu principal
                           when others => raise Data_Error;
                        end case;
                     exception
                        when others => put_line ("Saisie incorrecte"); new_line;	-- gestion de l'exception si l'user appuie sur une mauvaise touche
                     end;
                  end loop;

               when 'A' => affiche_attribut(base.contenu_base,table_cible);
                  if(table_cible/=NULL) then
                     loop
                        begin
                           put_line("-- GESTION DES ATTRIBUTS : --");
                           put_line("A: Ajouter un ou plusieurs attributs(s)");
                           put_line("S: Supprimer un ou plusieurs attributs(s)");
                           put_line("R: Retourner au menu principal");
                           text_IO.get_immediate(answer);
                           MAJ_char(answer);				-- conversion en majuscule pour éviter la casse
                           case answer is				-- navigation dans le sous menu
                              when 'A' => edit_attribut(Base.Contenu_Base,table_cible);	-- procedure qui ajoute un/des attribut(s)
                              when 'S' => supprimer(Base.contenu_base,table_cible);	-- procedure qui supprime un/des attribut(s)
                              when 'R' => exit;						-- revient au menu principal
                              when others => raise Data_Error;
                           end case;
                        exception
                           when others => put_line ("Saisie incorrecte"); new_line;
                        end;
                     end loop;
                  end if;
                  table_cible:=NULL;

               when 'D' => table_cible:=NULL;
                  if(Base.Contenu_Base/=NULL) then
                     if(Base.Contenu_Base.Contenu_Table /=NULL) then
                        loop
                           begin
                              put_line("-- GESTION DES DONNEES : --");
                              put_line("V: Afficher le contenu d'une table");
                              put_line("A: Ajouter une ou plusieurs donnees");
                              put_line("S: Supprimer un n-uplet");
                              put_line("R: Retourner au menu principal");
                              text_IO.get_immediate(answer);
                              MAJ_char(answer);
                              new_line;

                              case answer is					-- navigation dans le sous menu
                              when 'V' => table_cible:=NULL; affiche_donnees(Base.Contenu_Base,table_cible);	-- procedure qui affiche les n-uplets d'une table
                              when 'A' => edit_donnees(Base.Contenu_Base);					-- procedure qui ajoute un/des n-uplet(s) dans une table
                              when 'S' => supprimer_donnees(base.contenu_base,table_cible);			-- procedure qui supprime un/des n-uplet(s) dans une table
                              when 'R' => exit;									-- permet de revenir au menu principal
                              when others => raise Data_Error;
                              end case;
                           exception
                              when others => put_line ("Saisie incorrecte"); new_line;
                           end;
                        end loop;
                     else
                        new_line; put_line("WARNING - Aucun attribut");
                     end if;
                  else
                     new_line; put_line("WARNING - Base vide");
                  end if;
                  new_line;

               when 'E' => save_base(Base,Nom_fic,taille_fic);		-- procedure qui sauvegarde la base courante dans un fichier

               when 'S' => del_base(nom_fic,taille_fic, close);		-- procedure qui supprime le fichier contenant la base et quitte le programme
                  if close then
                     exit;
                  end if;

               when 'Q' => exit;					-- quitte le programme

               when others => Put_line("COMMANDE INTROUVABLE"); new_line;	-- si l'user se trompe de touche, message d'erreur

            end case;
         end;
      end loop;
   end if;

end Main;

   -- ====================================================================
   -- ================== Fin du programme principal ======================
   -- ====================================================================
