package fr.btytgat.odysseedesvagabonds.database

import fr.btytgat.odysseedesvagabonds.database.entities.*
import fr.btytgat.odysseedesvagabonds.utils.*

class DatabaseUtils {

    companion object {
        lateinit var infos: List<Info>

        fun initDatabase(databaseManager: DatabaseManager) {
            with(databaseManager) {
                infoDao().insertAllInfos(Info.populate())
                infos = infoDao().getAllInfos()

//
//                val classeGuerrier = classeDao().insertClasse(
//                    Classe.populateOneClasse(
//                        infos.first { info -> info.name == ClasseEnum.GUERRIER.label }.id,
//                        ClasseEnum.GUERRIER.healthDiceModifier,
//                        ClasseEnum.GUERRIER.manaDiceModifier
//                    )
//                )



                initClasseDruide()
                initClasseIngenieur()


                insertAllRaces()

            }
        }

        private fun DatabaseManager.initClasseDruide() {
            val classeDruide = classeDao().insertClasse(
                Classe.populateOneClasse(
                    infos.first { info -> info.name == ClasseEnum.DRUIDE.label }.id,
                    ClasseEnum.DRUIDE.healthDiceModifier,
                    ClasseEnum.DRUIDE.manaDiceModifier
                )
            )
            val voieBestiale = insertVoie(classeDruide, VoieEnum.VOIE_BESTIALE)
            insertRang(voieBestiale, RangEnum.RANG_1_BESTIALE)
            insertRang(voieBestiale, RangEnum.RANG_2_BESTIALE)
            insertRang(voieBestiale, RangEnum.RANG_3_BESTIALE)
            insertRang(voieBestiale, RangEnum.RANG_4_BESTIALE)
            insertRang(voieBestiale, RangEnum.RANG_5_BESTIALE)

            val voieProtecteur = insertVoie(classeDruide, VoieEnum.VOIE_DU_PROTECTEUR)
            insertRang(voieProtecteur, RangEnum.RANG_1_PROTECTEUR)
            insertRang(voieProtecteur, RangEnum.RANG_2_PROTECTEUR)
            insertRang(voieProtecteur, RangEnum.RANG_3_PROTECTEUR)
            insertRang(voieProtecteur, RangEnum.RANG_4_PROTECTEUR)
            insertRang(voieProtecteur, RangEnum.RANG_5_PROTECTEUR)

            val voieNature = insertVoie(classeDruide, VoieEnum.VOIE_DE_LA_NATURE)
            insertRang(voieNature, RangEnum.RANG_1_NATURE)
            insertRang(voieNature, RangEnum.RANG_2_NATURE)
            insertRang(voieNature, RangEnum.RANG_3_NATURE)
            insertRang(voieNature, RangEnum.RANG_4_NATURE)
            insertRang(voieNature, RangEnum.RANG_5_NATURE)

            val voieVegetaux = insertVoie(classeDruide, VoieEnum.VOIE_DES_VEGETAUX)
            insertRang(voieVegetaux, RangEnum.RANG_1_VEGETAUX)
            insertRang(voieVegetaux, RangEnum.RANG_2_VEGETAUX)
            insertRang(voieVegetaux, RangEnum.RANG_3_VEGETAUX)
            insertRang(voieVegetaux, RangEnum.RANG_4_VEGETAUX)
            insertRang(voieVegetaux, RangEnum.RANG_5_VEGETAUX)
        }

        private fun DatabaseManager.initClasseIngenieur() {
            val classeIngenieur = classeDao().insertClasse(
                Classe.populateOneClasse(
                    infos.first { info -> info.name == ClasseEnum.INGENIEUR.label }.id,
                    ClasseEnum.INGENIEUR.healthDiceModifier,
                    ClasseEnum.INGENIEUR.manaDiceModifier
                )
            )
            val voieArtillerie = insertVoie(classeIngenieur, VoieEnum.VOIE_DE_L_ARTILLERIE)
            insertRang(voieArtillerie, RangEnum.RANG_1_ARTILLERIE)
            insertRang(voieArtillerie, RangEnum.RANG_2_ARTILLERIE)
            insertRang(voieArtillerie, RangEnum.RANG_3_ARTILLERIE)
            insertRang(voieArtillerie, RangEnum.RANG_4_ARTILLERIE)
            insertRang(voieArtillerie, RangEnum.RANG_5_ARTILLERIE)

            val voieChimiste = insertVoie(classeIngenieur, VoieEnum.VOIE_DU_CHIMISTE)
            insertRang(voieChimiste, RangEnum.RANG_1_CHIMISTE)
            insertRang(voieChimiste, RangEnum.RANG_2_CHIMISTE)
            insertRang(voieChimiste, RangEnum.RANG_3_CHIMISTE)
            insertRang(voieChimiste, RangEnum.RANG_4_CHIMISTE)
            insertRang(voieChimiste, RangEnum.RANG_5_CHIMISTE)

            val voieTireur = insertVoie(classeIngenieur, VoieEnum.VOIE_DU_TIREUR)
            insertRang(voieTireur, RangEnum.RANG_1_TIREUR)
            insertRang(voieTireur, RangEnum.RANG_2_TIREUR)
            insertRang(voieTireur, RangEnum.RANG_3_TIREUR)
            insertRang(voieTireur, RangEnum.RANG_4_TIREUR)
            insertRang(voieTireur, RangEnum.RANG_5_TIREUR)

            val voieMecanique = insertVoie(classeIngenieur, VoieEnum.VOIE_DE_LA_MECANIQUE)
            insertRang(voieMecanique, RangEnum.RANG_1_MECANIQUE)
            insertRang(voieMecanique, RangEnum.RANG_2_MECANIQUE)
            insertRang(voieMecanique, RangEnum.RANG_3_MECANIQUE)
            insertRang(voieMecanique, RangEnum.RANG_4_MECANIQUE)
            insertRang(voieMecanique, RangEnum.RANG_5_MECANIQUE)
        }

        private fun DatabaseManager.insertVoie(idClasse: Long, voie: VoieEnum): Long {
            return voieDao().insertVoie(
                Voie.populateOneVoie(
                    infos.first { info -> info.name == voie.label }.id,
                    idClasse
                )
            )

        }

        private fun DatabaseManager.insertRang(idVoie: Long, rang: RangEnum){
            rangDao().insertRang(
                Rang.populateOneRang(
                    infos.first { info -> info.name == rang.label }.id,
                    idVoie,
                    rang.rangNumber
                )
            )
        }


        private fun DatabaseManager.insertAllRaces() {
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.DEMI_ELFE.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.DEMI_ORQUE.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.DRACONIEN.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.ELFE_SYLVAIN.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.HAUT_ELFE.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.GNOME.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.HUMAIN.label }.id))
            raceDao().insertRace(Race.populateOneRace(infos.first { info -> info.name == RaceEnum.NAIN.label }.id))
        }

    }


}