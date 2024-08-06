package fr.btytgat.odysseedesvagabonds.database.firebase

import android.util.Log
import com.google.firebase.database.DatabaseReference
import fr.btytgat.odysseedesvagabonds.database.enums.PathOriginEnum
import fr.btytgat.odysseedesvagabonds.database.enums.TalentTypeEnum
import fr.btytgat.odysseedesvagabonds.database.wrapper.InfoWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.PathWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.TalentGroupWrapper
import fr.btytgat.odysseedesvagabonds.database.wrapper.TalentWrapper
import java.util.*

class PathInitializer {

    companion object{
        val categoryVoieElement = "Voie des éléments"
        val nbVoieElement: Long = 2

        fun voieBestiale(database: DatabaseReference, classeUuid: String): PathWrapper{
            val categoryAnimalCompagnie = "ANIMAL_DE_COMPAGNIE"

            val infoTalent1_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de compagnie",
                "Panthère: +2 tests DEX",
                "",
                ""
            )
            infoTalent1_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.SUPPORT.name,
                false,
                null,
                isChoice = true,
                category = categoryAnimalCompagnie,
            )
            talent1_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent1_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de compagnie",
                "Loup: +2 tests CHA",
                "",
                ""
            )
            infoTalent1_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_2,
                TalentTypeEnum.SUPPORT.name,
                false,
                null,
                isChoice = true,
                category = categoryAnimalCompagnie,
            )
            talent1_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent1_3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de compagnie",
                "Aigle: +2 tests PER",
                "",
                ""
            )
            infoTalent1_3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_3,
                TalentTypeEnum.SUPPORT.name,
                false,
                null,
                isChoice = true,
                category = categoryAnimalCompagnie,
            )
            talent1_3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent1_4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de compagnie",
                "Autres? (a faire valider par le MJ)",
                "",
                ""
            )
            infoTalent1_4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_4,
                TalentTypeEnum.SUPPORT.name,
                false,
                null,
                isChoice = true,
                category = categoryAnimalCompagnie,
            )
            talent1_4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Animal de compagnie",
                1,
                listOf(talent1_1, talent1_2, talent1_3, talent1_4)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Transformation minime",
                "Transformation (pour soi uniquement) en un minimal minuscule ou petit (souris, chat, moineau, petit poisson) pendant 1d6 + INT min",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2,
                TalentTypeEnum.ACTIF.name,
                true,
                2,
                manaCost = true,
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Transformation minime",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de combat",
                "L'animal de compagnie est désormais capable d'attaquer au tour de son compagnon, +RANG AdC et 1d6 DMG",
                "",
                ""
            )
            infoTalent3_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent3_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Animal de combat",
                "Le bonus du compagnon passe à +4",
                "",
                ""
            )
            infoTalent3_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_2,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent3_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Animal de combat",
                3,
                listOf(talent3_1, talent3_2)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Mutation partielle",
                "change une partie du corps (aile, branchies, patte de lézard pour escalader, patte d'araignées, bras de gorille)",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.ACTIF.name,
                true,
                2,
                manaCost = true,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Mutation partielle",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Transformation majeure",
                "transformation en grand animal (gorille, loup, lion, requin, aigle royal) + utilisable sur INT autres cibles consentante",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5,
                TalentTypeEnum.ACTIF.name,
                true,
                2,
                manaCost = true,
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Transformation majeure",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie bestiale",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie bestiale",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieProtecteur(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Peau d'écorce",
                "+1 DEF CaC, +1 DEF distance",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Peau d'écorce",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Écorce partagé",
                "partage le bonus avec ses alliés pour INT tours",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Écorce partagé",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Brume",
                "invoque un brouillard dense autour du groupe pendant 1d6 + INT tours, +5 discrétion, -5 AdC, -5 AdT, -5 tests d'attaque magique",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Brume",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Instinct de survie",
                "frisson lorsqu'un danger approche (test diff 18 de PER (caché) pour savoir s'il est mortel ou non)",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Instinct de survie",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Pissenlit protecteur",
                "un pissenlit géant pousse autour du lanceur (ou d'une cible) afin de protéger de dégâts extérieurs max INT personnes,  jusqu'à 4 x NIVEAU x INT DMG pendant 2d6 + INT tours",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Pissenlit protecteur",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du protecteur",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du protecteur",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieNature(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Enfant de la nature",
                "+2 / rang aux tests de déplacements (DEX et CON) et de survies en environnement difficiles (collines, montagnes, neiges, ... )",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Enfant de la nature",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Calme animal",
                " +2 / rang aux tests de SOC pour calmer et comprendre les émotions des animaux (faim, peur, curiosité, ...)",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
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
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Calme animal",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Fruit de la vie",
                "fait pousser un petits arbres fruitiers contenant RANG fruits magique qui rendent chacun 1d6 + INT PV (se conserve 1 journée max, nécessite d'être dans la nature, entouré de végétation)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Fruit de la vie",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Invocation animal",
                "invoque un animal magique de taille moyenne au côté du joueur ",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Invocation animal",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Tempête menaçante",
                "+2 CON",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Tempête menaçante",
                "Le druide prépare une tempête faite de bourrasque et d'éclairs et de grêle, représente la colère et la puissance de la nature, inflige 4D6 sur une zone de 20m de diamètre",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5_2,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Tempête menaçante",
                5,
                listOf(talent5_1, talent5_2)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de la nature",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de la nature",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieVegetaux(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Vie sylvestre",
                "+3 INIT et +2 tests de PER si entouré de végétation",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Vie sylvestre",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Se fondre dans la nature",
                "+5 discrétion pour se fondre dans la nature",
                "",
                ""
            )
            infoTalent2_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null
            )
            talent2_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent2_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Se fondre dans la nature",
                "peut l'appliquer à INT alliés ",
                "",
                ""
            )
            infoTalent2_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent2_2,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Se fondre dans la nature",
                2,
                listOf(talent2_1, talent2_2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Lianes immobilisantes",
                "fait pousser des lianes très rapidement aux pieds de ses énemis les empechant de bouger pendant 1d6 / 2 tours (réduits par 2 sur les grandes et+ créatures) ",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent3,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Lianes immobilisantes",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Arbrification",
                " transformation qn ou soi meme en arbre, l'empêchant d'agir ou de bouger, gagne 10 de RD physique, régénère 1d6 PV par tour, peut être annulé par le lanceur,  si c'est qn d'autre test d'opposition de CON pour en sortir; et le sort dure INT tours. ",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent4,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Arbrification",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Plante carnivore",
                "fait sortir de sol une très grandes plantes carnivores qui obéit au druide ou attaque les ennemis à portée",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent5,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Plante carnivore",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie des végétaux",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie des végétaux",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }


        fun voieArtillerie(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Apprenti artilleur",
                "+2 / rang au test liés au fait de maitriser, utiliser et comprendre le fonctionnement d'une arme de siège",
                "",
                ""
            )
            infoTalent1_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent1_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Apprenti artilleur",
                "maitrise des armes à poudres et des armes de sièges",
                "",
                ""
            )
            infoTalent1_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_2,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Apprenti artilleur",
                1,
                listOf(talent1_1, talent1_2)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Canon à mains",
                "retrouve/trouve/achète/obtient (à voir avec le MJ) un petit canon à mains, permet de tirer un boulet, portée 40m, 3D10 DMG, rechargement = action complexe (rechargement rapide ne marche pas sur ce canon)",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.ACTIF.name,
                false,
                1,
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Canon à mains",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur confirmé",
                "rechargement canon à 2 mains = action de mouvement",
                "",
                ""
            )
            infoTalent3_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent3_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur confirmé",
                "+2 DMG avec des armes à poudre légères",
                "",
                ""
            )
            infoTalent3_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent3_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur confirmé",
                "+5 DMG avec des armes à poudres lourdes",
                "",
                ""
            )
            infoTalent3_3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent3_3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Artilleur confirmé",
                3,
                listOf(talent3_1, talent3_2, talent3_3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Médecin de campagne",
                "peut stabiliser une personne blessé physiquement et lui rend 4D4 PV",
                "",
                "une nouvelle technique qui vient de la sence, stence, sience, je sais plus, bref, ca marche sans magie y parait"
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.ACTIF.name,
                false,
                1,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Médecin de campagne",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur vétéran",
                "peut prendre la tête d'une unité de siège (légitime / pas de négociation à faire)",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur confirmé",
                "+10 tests d'attaque pour toucher une structure avec une arme de siège ou à poudre",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artilleur confirmé",
                "+5 tests d'attaque pour toucher une créature (+10 si celle-ci est grande ou plus ou qu'il s'agit d'un très grand groupe d'ennemis)",
                "",
                ""
            )
            infoTalent5_3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Artilleur vétéran",
                5,
                listOf(talent5_1, talent5_2, talent5_3)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de l'artillerie",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de l'artillerie",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieChimiste(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chimiste en herbe",
                "+2 / rang au test pour réaliser de la poudre à canon, pour les armes à feu ou pour réaliser des potions, fabrication max RANGx2 potions par jour, 10min de préparation pour chaque",
                "",
                ""
            )
            infoTalent1_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent1_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chimiste en herbe",
                "déblocage: potion de santé",
                "",
                ""
            )
            infoTalent1_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Chimiste en herbe",
                1,
                listOf(talent1_1, talent1_2)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoTalent2_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Expertise de la poudre",
                "ajoute sa DEX aux dégâts d'une arme à feu",
                "",
                ""
            )
            infoTalent2_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent2_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent2_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Expertise de la poudre",
                "déblocage: potion de fer",
                "",
                ""
            )
            infoTalent2_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent2_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Expertise de la poudre",
                2,
                listOf(talent2_1, talent2_2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }




            val infoTalent3_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Projectile explosif",
                "permet de fabriquer un petit projectile qui explose à l'impact sur un rayon de 3-4m, en infligeant 2D6 DMG, temps de fabrication d'un projectile = 1h, test d'attaque / lancer de DEX",
                "",
                ""
            )
            infoTalent3_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent3_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Projectile exposif",
                "déblocage: potion de poison",
                "",
                ""
            )
            infoTalent3_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent3_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Projectile explosif",
                3,
                listOf(talent3_1, talent3_2)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }




            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Démolisseur",
                "permet de fabriquer une charge d'explosif permettant de percer un mur, une structure ou un coffre,  temps d'installation d'une charge = 2 tours, temps de fabrication d'une charge = 3h",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Démolisseur",
                "déblocage: potion de réussite (bonus aux jets)",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Démolisseur",
                4,
                listOf(talent2_1, talent2_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }





            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Sapeur",
                "projectile explosif: le rayon passe à 4-6m, les dégats passe à 4d6",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Sapeur",
                "amélioration démolisseur",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Sapeur",
                "déblocage: potions magiques (nécessite l'aide d'un magicien connaissant le sort)",
                "",
                ""
            )
            infoTalent5_3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1_1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Sapeur",
                5,
                listOf(talent5_1, talent5_2, talent5_3)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du chimiste",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du chimiste",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieTireur(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Entraînement au tir",
                "+1 AdT / rang avec des armes à feu",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Entraînement au tir",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Tenir en joue",
                "action de mouvement: tient en joue une cible, qui subit une attaque gratuite de l'ingénieur s'il se déplace",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Tenir en joue",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }




            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Pistoléro",
                "peut utiliser deux armes à feu à une main en même temps en utilisant un D12 au lieu d'un D20 pour toucher sa cible, 2 tirs possibles dans le tour comme une action d'attaque (si un seul tir --> D20 et un bonus supplémentaire de +2)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Pistoléro",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }




            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réchargement rapide",
                "rechargement gratuit après avoir tiré (ne marche pas avec 2 armes équipés)",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Réchargement rapide",
                "amélioration tenir en joue: peut tenir 3 cibles proches en joue (ne peut tirer qu'une fois en réaction dans un tour)",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Rechargement rapide",
                4,
                listOf(talent2, talent4_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }





            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - As de la gachette",
                "amélioration pistoléro: utilise des D20 (avec 2 armes équipés) et ajoute 2D10 dégâts avec 1 seule arme équipé",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - As de la gachette",
                "amélioration rechargement rapide: marche dorénavant avec 2 armes équipés",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - As de la gachette",
                5,
                listOf(talent5_1, talent5_2)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }




            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du tireur",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du tireur",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieMecanismes(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Mécanicien",
                "+2 / rang aux tests liés à la mécanique et à la compréhension d'un mécanisme (engrenage, piston, marchines, ...)",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Mécanicien",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Physique appliquée",
                "+5 aux tests de FOR ou DEX / pouvant être optimisé par des connaissances physique poussées (utiliser un levier pour soulever qch de lourd, peut s'appliquer au lancer de projectile explosif)",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                true,
                null,
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Physique appliquée",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Automate",
                "permet de fabriquer un petit automate d'engrenage et de métal qui peut porter du matériel ou tout simplement être vendu à des riches ",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                true,
                null
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Automate",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Bidouillage",
                "peut améliorer une arme à poudre pour l'équivalent de 10pa de pièces) :\n" +
                        "crosse modifiée : +3AdT\n" +
                        "canon vissé: +1D6 DMG\n" +
                        "chargeur: peut tirer 2 balles de plus sans recharger (augmente d'autant le nombre de réaction avec tenir en joue dans un même tour)",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Bidouillage",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Golem",
                "l'ingénieur peut se construire une golem et lui installer un module permettant de le spécialiser :\n" +
                        "- artilleur -> canon sur l'épaule\n" +
                        "- protecteur -> bouclier sur le bras\n" +
                        "- mobile -> allégement de la structure, moins encombrant et moins gêné par les endroit exigus\n" +
                        "- combattant -> armes de CaC ou mains faite pour se battre\n" +
                        "- mûle -> buste ouvrable faisant office de rangement\n",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                true,
                null
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Golem",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie des mécanismes",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie des mécanismes",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }


        fun voieFeu(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esprit du phoenix",
                "Le mage gagne petit à petit une résistance au dégâts de feu, cela s'illustre par des tatouages magiques rouge sur son corps. +1 RD feu / rang",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Esprit du phoenix",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Boule de feu",
                "tire une boule de feu sur un enemi en infligeant 2d6",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Boule de feu",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Mur de flamme",
                "crée un mur de flamme jusqu'à 1d8 + INT mètres de large pendant 1d6 + INT tours, qui inflige 3d6 de feu à ceux qui veulent le traverser",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Mur de flamme",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Contrôle du feu",
                "amélioration boule de feu: les degâts passent à 3d6",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Contrôle du feu",
                "pour intensifier, éteindre, donner une forme (controle minimal (cf doigt briquet, a le cout en mana d'un rang 1) permet de donner une forme au mur de flamme",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Contrôle du feu",
                4,
                listOf(talent4_1, talent4_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Élémentaire de feu",
                "invoquer ou se transformer en élémentaire (+10RD feu)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Élémentaire de feu",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie du feu",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie du feu",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid,
                categoryVoieElement,
                nbVoieElement
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieTerre(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esprit de Gaia",
                "Le mage gagne petit à petit une résistance au dégâts physique, cela s'illustre par des tatouages magiques vert sur son corps. +1 RD physique / rang",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Esprit de Gaia",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Prison terrestre",
                "ouvre le sol sous les pieds d'une cible pour l'emprisonner (taille moyenne max, rang 4 taille grande max)",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Prison terrestre",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Poing de pierre",
                "invoque un poing de pierre qui sort du sol pour frapper une cible",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Poing de pierre",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Sens tellurique",
                "permet de détecter tout mouvement sur et sous le sol, détection sur 100m / min passé à se concentrer dessus",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                2,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Sens tellurique",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Élémentaire de pierre",
                "invoquer ou se transformer en élémentaire de pierre (+10RD physique)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Élémentaire de pierre",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de la terre",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de la terre",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid,
                categoryVoieElement,
                nbVoieElement
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieEau(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esprit de Neptune",
                "Le mage gagne petit à petit une résistance au dégâts de glace, cela s'illustre par des tatouages magiques bleus sur son corps. +1 RD glace / rang",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Esprit de Neptune",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Lance de givre",
                "invoque et projette une lance de givre, qui peut transpercer une cible",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Lance de givre",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Soutien marin",
                "peut respirer sous l'eau 10min sans gêne (puis applique la gestion de la respiration sous l'eau normalement)",
                "",
                ""
            )
            infoTalent3_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                true,
                null
            )
            talent3_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Soutien marin",
                "peut, en lançant un sort, permettre à lui-même ou qn d'autre d'en profiter",
                "",
                ""
            )
            infoTalent3_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Soutien marin",
                3,
                listOf(
                    talent3_1, talent3_2
                )
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Prison aqueuse",
                "Amélioration lance de givre",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Prison aqueuse",
                "créer une sphère d'eau autour d'une cible afin de la blesser/noyer",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Prison aqueuse",
                4,
                listOf(talent4_1, talent4_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Élémentaire de d'eau",
                "invoquer ou se transformer en élémentaire d'eau (+10RD feu)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Élémentaire de glace",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de l'eau",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de l'eau",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid,
                categoryVoieElement,
                nbVoieElement
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieAir(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esprit de Zéphyr",
                "Le mage gagne petit à petit une résistance au dégâts de foudre, cela s'illustre par des tatouages magiques blancs sur son corps. +1 RD foudre / rang",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Esprit de Zéphyr",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Murmure du vent",
                "peut parler ou écouter qn jusqu'à 100m",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                false,
                1,
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Murmure du vent",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Mur d'air",
                "dévie les projectiles qui arrive dans la direction du mage et de ses alliés proches de lui, +10 de DEF contre les projectiles",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Mur d'air",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Chaine d'éclairs",
                "projette un éclair sur un ennemi, qui peut se projeter sur jusqu'à 3 autres cibles (jet d'attaques magiques pour les suivants avec malus de -3 à chaque rebond et dégats réduits de 2 par nouvelles cibles)",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Chaine d'éclairs",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Élémentaire d'air",
                "invoquer ou se transformer en élémentaire (+5RD foudre)",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Élémentaire d'air",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de l'air",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de l'air",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid,
                categoryVoieElement,
                nbVoieElement
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieArcane(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Esprit arcanique",
                "Le mage gagne petit à petit une résistance au dégâts à la magie, cela s'illustre par des tatouages magiques violets sur son corps. +1 RD magique/ rang",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Esprit arcanique",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Éclat des arcanes",
                "tire un éclat de magie pure qui ne peut être esquivé, 1d6",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Éclat des arcanes",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Agrandissement",
                "accroit la taille d'un allié (ou lui-même)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Agrandissement",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Artéfact magique",
                "obtient une arme ou un accessoire renforcé",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Artéfact magique",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Déchainement des arcanes",
                "déchainement de puissance arcanique qui provoque une explosion désintégrant ce qu'elle touche, 5d6 + INT DMG",
                "",
                ""
            )
            infoTalent5.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Déchainement des arcanes",
                5,
                listOf(talent5)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie des arcanes",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie des arcanes",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid,
                categoryVoieElement,
                nbVoieElement
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieMagieUniverselle(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Savoir magique",
                "+1 / RANG aux tests liés aux connaissance et savoirs occultes ou liés à la magie",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Savoir magique",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Cercle de protection",
                "créer un cercle pouvant contenir jusqu'à INT personnes, pour qui il donne +3 à la DEF MAG aux autres joueurs, le cercle dure INT + 1d4 tours et le sort est brisé si le magicien en sort. au rang 4, le mage peut intercepter les sorts adverses (visant ses alliés dans le cercle), et utiliser sa défense magique en conséquence",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Cercle de protection",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Transfert de mana",
                "permet de transférer le mana d'une personne à une autre, si consentante: action simple, sinon : action d'attaque magique, débit de transfert: DM du magicien par action ",
                "",
                ""
            )
            infoTalent3_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent3_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Transfert de mana",
                "permet de dépasser son maximum de mana pendant une faible période de temps, sans subir d'overdose magique (durée dépassement =  INT * 2 min) ",
                "",
                ""
            )
            infoTalent3_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                true,
                null,
            )
            talent3_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Transfert de mana",
                3,
                listOf(talent3_1, talent3_2)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Téléportation",
                "permet de téléporter, le magicien (+ des alliés) sur une grande distance, cout en mana très élevé. \n" +
                        "cout en mana = N * D\n" +
                        "N = nombre de personnes\n" +
                        "D = distance (km)",
                "",
                ""
            )
            infoTalent4.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                2,
                manaCost = true
            )
            talent4.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Téléportation",
                4,
                listOf(talent4)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Archimage",
                "titre d'archimage, +2 INT",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Archimage",
                "possibilité de lancer 2 sorts dans un même tour (1d12 pour des sorts d'attaque magique et effets / 2 pour les autres sorts, déplacement dans ce tour impossible)",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                true,
                null,
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Archimage",
                5,
                listOf(talent5_1)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de la magie universelle",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de la magie universelle",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
        fun voieLumiere(database: DatabaseReference, classeUuid: String): PathWrapper {
            val infoTalent1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Orbe de lumière",
                "crée un orbe de lumière qui flotte près du magicien pendant INT tours",
                "",
                ""
            )
            infoTalent1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup1 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#1 - Orbe de lumière",
                1,
                listOf(talent1)
            )
            talentGroup1.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Lueur scintillante",
                "aveugler ou dissiper des ténèbres",
                "",
                ""
            )
            infoTalent2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup2 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#2 - Lueur scintillante",
                2,
                listOf(talent2)
            )
            talentGroup2.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent3 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Perception vitale",
                "permet de percevoir le nombre et une direction approximative des entités vivantes autour du mage (jusqu'à max RANG * 10 mètres)",
                "",
                ""
            )
            infoTalent3.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent3 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent3.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup3 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#3 - Perception vitale",
                3,
                listOf(talent3)
            )
            talentGroup3.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }

            val infoTalent4_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Armure du zénith",
                "amélioration orbe de lumière: l'orbe de lumière dure maintenant INT + RANG tours",
                "",
                ""
            )
            infoTalent4_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.REINFORCEMENT.name,
                false,
                null,
            )
            talent4_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent4_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Armure du zénith",
                "bouclier 20 + INT * RANG",
                "",
                ""
            )
            infoTalent4_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent4_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent4_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup4 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#4 - Armure du zénith",
                4,
                listOf(talent4_1, talent4_2)
            )
            talentGroup4.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }


            val infoTalent5_1 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Bannissement",
                "+2 INT",
                "",
                ""
            )
            infoTalent5_1.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_1 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.PASSIF.name,
                false,
                null,
            )
            talent5_1.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val infoTalent5_2 = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Bannissement",
                "lève la conjuration d'une entité invoqué (cout = cout du rang du sort d'invocation)",
                "",
                ""
            )
            infoTalent5_2.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talent5_2 = TalentWrapper(
                UUID.randomUUID().toString(),
                infoTalent1,
                TalentTypeEnum.ACTIF.name,
                true,
                1,
                manaCost = true
            )
            talent5_2.let {
                Log.i("DATABASE", "create talent - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENTS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val talentGroup5 = TalentGroupWrapper(
                UUID.randomUUID().toString(),
                "#5 - Bannissement",
                5,
                listOf(talent5_1, talent5_2)
            )
            talentGroup5.let {
                Log.i("DATABASE", "create talentGroup - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_TALENT_GROUPS)
                    .child(it.uuid.toString()).setValue(it)
            }



            val infoPath = InfoWrapper(
                UUID.randomUUID().toString(),
                "Info - Voie de la lumière",
                "",
                "",
                ""
            )
            infoPath.let {
                Log.i("DATABASE", "create info - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_INFOS)
                    .child(it.uuid.toString()).setValue(it)
            }
            val path = PathWrapper(
                UUID.randomUUID().toString(),
                "Voie de la lumière",
                infoPath,
                listOf(
                    talentGroup1,
                    talentGroup2,
                    talentGroup3,
                    talentGroup4,
                    talentGroup5,
                ),
                PathOriginEnum.CLASSE.name,
                classeUuid
            )
            path.let {
                Log.i("DATABASE", "create path - ${it.uuid}")
                database.child(FirebaseUtils.KEY_SYSTEM).child(FirebaseUtils.KEY_PATHS)
                    .child(it.uuid.toString()).setValue(it)
            }
            return path
        }
    }
}