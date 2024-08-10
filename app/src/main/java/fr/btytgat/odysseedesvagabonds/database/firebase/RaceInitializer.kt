package fr.btytgat.odysseedesvagabonds.database.firebase

import com.google.firebase.database.DatabaseReference

class RaceInitializer {

    companion object {
        fun populateRaces(database: DatabaseReference) {
//            nain(database)
//            gnome(database)
//            hautElfe(database)
//            elfeSylvain(database)
        }


/*
        fun gnome(database: DatabaseReference) {
            val infoTalent1_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Accessoire vraisemblablement indispensable",
                "Maitrise d'une arme ou d'un instrument de musique au choix, si choix d'une arme/instrument déjà maitrisé, donne +1 AdC/+1AdT et +1 DMG avec cette arme à la place (si instrument déja maitrisé, +2 pour un instrument)",
                "",
                ""
            )
            infoTalent1_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent1_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent1_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Accessoire vraisemblablement indispensable",
                "possède un porte bonheur (petit objet) qui lui donne +1 CHAN tant qu'il l'a sur lui",
                "",
                ""
            )
            infoTalent1_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_2,
                TalentTypeEnum.SUPPORT.name,
                false,
                null
            )
            talent1_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Accessoire vraisemblablement indispensable",
                1,
                listOf(talent1_1, talent1_2)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Discussion insensée mais soit disant pertinente",
                "une fois par combat, si la cible du gnome est humanoïde et comprend sa langue, le gnome peut raconter sa vie au milieu du combat afin de perturber sa cible, test de SOC du gnome en opposition à un test de CHA de la cible. Si réussite, -3 dans toutes les DEF de la cible jusqu'au prochain tour + perte de son action d'attaque pour ce tour si elle joue après le gnome",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2,
                TalentTypeEnum.ACTIF.name,
                false,
                2,
                false,
                false,
                "une fois par cible par combat (impossible de l'utiliser sur les cibles à proximité des victimes de cette compétence)"
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Discussion insensée mais soit disant pertinente",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Dans ma sacoche j'ai ...",
                "retrouve, trouve, achète (à avoir avec le MJ) une petite sacoche qui peut contenir jusqu'à 50kg d'objets en tout genre (non vivant uniquement, la nourriture ne se conserve pas mieux qu'en dehors) (le sac ne pèse rien pour le gnome)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.SUPPORT.name,
                false,
                null
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Dans ma sacoche j'ai ...",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - P'tit bonhomme",
                "+3 DEF contre les ennemis de grandes tailles, +6 DEF contre les ennemis plus grands encore",
                "s'ils n'exprimaient pas aussi souvent leurs idées farfelues, les gnomes seraient les meilleurs ninjas qui existent",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - P'tit bonhomme",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chanceux",
                "+2 CHAN",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chanceux",
                "une fois par aventure, si doit subir des dégâts mortels d'une attaque, ne meurt pas et regagne 2d6 PV et son porte bonheur est détruit (perd donc son +1 CHAN)",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_2,
                TalentTypeEnum.PASSIF.name,
                true,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Chanceux",
                5,
                listOf(talent5_1, talent5_2)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du gnome",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val raceUuid = UUID.randomUUID().toString();
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du gnome",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5
                ),
                PathOriginEnum.RACE.name,
                raceUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMap = java.util.HashMap<String, Long>()
            hashMap["STAT_SOC"] = 2
            hashMap["STAT_CHAN"] = 2
            hashMap["STAT_FOR"] = -2
            hashMap["STAT_CHA"] = -2
            val statChange = StatChangeWrapper(
                "STAT_CHANGE_GNOME",
                "Stat raciale - gnome",
                hashMap
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - gnome",
                "petit, bavard, curieux et pas toujours mignon",
                "",
                "vivent entre eux généralement"
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = RaceWrapper(
                raceUuid,
                "Gnome",
                6,
                6,
                info,
                path,
                statChange,
                listOf(
                    RaceTagEnum.BALANCED.name
                )
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }

        fun hautElfe(database: DatabaseReference) {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Sagesse ancestrale",
                " +5 tests liés aux tests sur les différentes races du continents et sur des évènements historiques passés",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Sagesse ancestrale",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Affinité magique",
                " +5 SOC pour parler une créature magique et +5 INT pour comprendre une créature magiqu",
                "ca tient chaud dans les profondeurs de la terre",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Affinité magique",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Puit d'arcane",
                "une fois par jour, puise dans son être intérieur l'énergie dont il aurait besoin pour lancer des sorts, perd 1d10 PV, pour regagner RANG d6 mana  ",
                "(ne peut pas dépasser son montant de mana max à moins d'avoir le dépassement de mana  (magicien, voie magie universelle, rang 3)",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.ACTIF.name,
                false,
                1,
                false,
                false,
                "une fois par jour"
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Puit d'arcane",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Visage impensable",
                "une fois par jour, l'elfe peut prendre les traits d'un être monstrueux et dangereux qui a disparus des millénaires plus tôt (cf gandalf chez bilbo), lui donne +10 SOC, +10 CHA pour faire fuir ou convaincre les gens autour de lui",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.ACTIF.name,
                false,
                null,
                false,
                false,
                "une fois par jour"
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Visage impensable",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Vitalité elfique",
                "augmente son dé de vie au dé 6 ",
                "retro actif",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Vitalité elfique",
                "peut lancer 2 dé aux tests de CON (et prendre le meilleur résultat) ",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_2,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Vitalité elfique",
                5,
                listOf(talent5_1, talent5_2)
            )

            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du haut-elfe",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val raceUuid = UUID.randomUUID().toString();
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du haut-elfe",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5
                ),
                PathOriginEnum.RACE.name,
                raceUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMapNain = java.util.HashMap<String, Long>()
            hashMapNain["STAT_DEX"] = 2
            hashMapNain["STAT_INT"] = 2
            hashMapNain["STAT_FOR"] = -2
            hashMapNain["STAT_SOC"] = -2
            val statChange = StatChangeWrapper(
                "STAT_CHANGE_HAUT_ELFE",
                "Stat raciale - haut-elfe",
                hashMapNain
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - haut-elfe",
                "aime la magie, être hautain et desteste les nains",
                "",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = RaceWrapper(
                raceUuid,
                "Haut-elfe",
                4,
                8,
                info,
                path,
                statChange,
                listOf(
                    RaceTagEnum.MAGIC.name
                )
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }

        fun elfeSylvain(database: DatabaseReference) {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Nature primordiale",
                "+5 INT aux tests liés à la connaissance d'une plante, d'un arbre ou d'un animal",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Nature primordiale",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Cri sauvage",
                "test difficulté 10 pour imiter le cri / bruit, d'un animal qu'il connait",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2,
                TalentTypeEnum.ACTIF.name,
                false,
                1
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Cri sauvage",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Amis de la forêt",
                "une fois par jour, en pleine nature (ou il y a de la vie), l'elfe sylvain pousse un puissant cri, qui appelle des animaux proches qui attaquent des ennemis au hasard",
                " test de CON pour définir les dégâts :\n" +
                        "1-5: 1d6 DMG\n" +
                        "6-10: 2x 1d6 DMG\n" +
                        "11-15: 3x 1d6 DMG\n" +
                        "16-19: 4x 1d6 DMG\n" +
                        "20: 5x 1d6 DMG ",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.ACTIF.name,
                false,
                2,
                false,
                false,
                "une fois par jour"
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Amis de la forêt",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Équipement naturel",
                "ajoute 1d6 à ses armes et +2 DEF à ses armures qui ne contiennent pas de métal",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Équipement naturel",
                "n'a plus de malus de DEX lié) à la DEF  si celle-ci n'est pas métallique",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4_2,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Équipement naturel",
                4,
                listOf(talent4_1, talent4_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Harmonie avec la nature",
                "+1 DEX et +1 CON",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Harmonie avec la nature",
                "avantage sur le jet de CON de la compétence de niveau 3 amis de la forêt",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Harmonie avec la forêt",
                5,
                listOf(talent5_1, talent5_2)
            )

            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de l'elfe sylvain",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val raceUuid = UUID.randomUUID().toString()
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de l'elfe-sylvain",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5
                ),
                PathOriginEnum.RACE.name,
                raceUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }


            var hashMapNain = java.util.HashMap<String, Long>()
            hashMapNain["STAT_DEX"] = 2
            hashMapNain["STAT_FOR"] = -1
            val statChange = StatChangeWrapper(
                "STAT_CHANGE_ELFE_SYLVAIN",
                "Stat raciale - elfe-sylvain",
                hashMapNain
            )
            statChange.let {
                Log.i("DATABASE", "create statChange - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_STAT_CHANGES)
                    .child(it.uuid.toString()).setValue(it)
            }


            val info = InfoWrapper(
                raceUuid,
                "Info - elfe-sylvain",
                "probablement né dans la foret",
                "aime faire des choses avec les abres, ou comme ils aiment l'appeller 'entrer en communion avec la nature'",
                ""
            )

            info.let {
                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val race = RaceWrapper(
                UUID.randomUUID().toString(),
                "Elfe-sylvain",
                8,
                6,
                info,
                path,
                statChange,
                listOf(
                    RaceTagEnum.BALANCED.name
                )
            )
            race.let {
                Log.i("DATABASE", "create race - ${it.uuid.toString()}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_RACES)
                    .child(it.uuid.toString()).setValue(it)
            }

        }
*/

    }

}