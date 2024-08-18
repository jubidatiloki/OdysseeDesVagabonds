package fr.btytgat.odysseedesvagabonds.database.firebase.initializers.classes

import com.google.firebase.database.DatabaseReference

class ClasseInitializer {

    companion object {
        fun populateClasses(database: DatabaseReference) {
//            druide(database)
//            ingenieur(database)
//            magicien(database)

        }

//        fun druide(database: DatabaseReference){
//            val info = InfoWrapper(
//                UUID.randomUUID().toString(),
//                "Info - Druide",
//                "fait des chose aux arbres et aux animaux pour ... la communion avec la nature",
//                "",
//                ""
//            )
//            info.let {
//                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_INFOS)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//            val classeUuid = UUID.randomUUID().toString()
//            val classe = ClasseWrapper(
//                classeUuid,
//                "Druide",
//                0,
//                1,
//                info,
//                listOf(
//                    PathInitializer.voieBestiale(database, classeUuid),
//                    PathInitializer.voieProtecteur(database, classeUuid),
//                    PathInitializer.voieNature(database, classeUuid),
//                    PathInitializer.voieVegetaux(database, classeUuid)
//                ),
//                listOf(
//                    ClasseTagEnum.MAGIC.name,
//                    ClasseTagEnum.SPELL.name,
//                    ClasseTagEnum.UTILITY.name
//                )
//            )
//            classe.let {
//                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_CLASSES)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//        }
//
//        fun ingenieur(database: DatabaseReference){
//            val info = InfoWrapper(
//                UUID.randomUUID().toString(),
//                "Info - Ingénieur",
//                "sait lire, écrire, compter, faire des calcul et utiliser une baliste d'une demi-tonne",
//                "",
//                ""
//            )
//            info.let {
//                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_INFOS)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//            val classeUuid = UUID.randomUUID().toString()
//            val classe = ClasseWrapper(
//                classeUuid,
//                "Ingénieur",
//                1,
//                -1,
//                info,
//                listOf(
//                    PathInitializer.voieArtillerie(database, classeUuid),
//                    PathInitializer.voieChimiste(database, classeUuid),
//                    PathInitializer.voieTireur(database, classeUuid),
//                    PathInitializer.voieMecanismes(database, classeUuid)
//                ),
//                listOf(
//                    ClasseTagEnum.PHYSICAL.name,
//                    ClasseTagEnum.SKILL.name,
//                    ClasseTagEnum.UTILITY.name
//                )
//            )
//            classe.let {
//                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_CLASSES)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//        }
//
//        fun magicien(database: DatabaseReference) {
//            val info = InfoWrapper(
//                UUID.randomUUID().toString(),
//                "Info - Magicien",
//                "est capable d'épater la gallerie avec la magie",
//                "",
//                ""
//            )
//            info.let {
//                Log.i("DATABASE", "create info - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_INFOS)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//            val classeUuid = UUID.randomUUID().toString()
//            val classe = ClasseWrapper(
//                classeUuid,
//                "Magicien",
//                -1,
//                1,
//                info,
//                listOf(
//                    PathInitializer.voieFeu(database, classeUuid),
//                    PathInitializer.voieTerre(database, classeUuid),
//                    PathInitializer.voieEau(database, classeUuid),
//                    PathInitializer.voieAir(database, classeUuid),
//                    PathInitializer.voieArcane(database, classeUuid),
//                    PathInitializer.voieMagieUniverselle(database, classeUuid),
//                    PathInitializer.voieLumiere(database, classeUuid),
//                ),
//                listOf(
//                    ClasseTagEnum.MAGIC.name,
//                    ClasseTagEnum.SKILL.name
//                )
//            )
//            classe.let {
//                Log.i("DATABASE", "create classe - ${it.uuid.toString()}")
//                database.child(KEY_SYSTEM).child(KEY_CLASSES)
//                    .child(it.uuid.toString()).setValue(it)
//            }
//        }
    }




}