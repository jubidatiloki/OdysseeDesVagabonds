package fr.btytgat.odysseedesvagabonds.database.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import fr.btytgat.odysseedesvagabonds.database.EntityEnum
import fr.btytgat.odysseedesvagabonds.utils.ClasseEnum
import fr.btytgat.odysseedesvagabonds.utils.RaceEnum
import fr.btytgat.odysseedesvagabonds.utils.RangEnum
import fr.btytgat.odysseedesvagabonds.utils.VoieEnum


@Entity(tableName = "info")
data class Info(
    @PrimaryKey(autoGenerate = true) var id: Long?,
    var name: String,
    var entity: String,
    var description: String? = "",
    var history: String? = "",

) {

    constructor(): this(id = null, name = "", entity = "", description = null, history = null)

    companion object{

        fun populate(): List<Info>{
            return listOf(
                Info(id = null, name = RaceEnum.DEMI_ELFE.label, entity = EntityEnum.RACE.name, description = RaceEnum.DEMI_ELFE.description, history = RaceEnum.DEMI_ELFE.history),
                Info(id = null, name = RaceEnum.DEMI_ORQUE.label, entity = EntityEnum.RACE.name, description = RaceEnum.DEMI_ORQUE.description, history = RaceEnum.DEMI_ORQUE.history),
                Info(id = null, name = RaceEnum.DRACONIEN.label, entity = EntityEnum.RACE.name, description = RaceEnum.DRACONIEN.description, history = RaceEnum.DRACONIEN.history),
                Info(id = null, name = RaceEnum.ELFE_SYLVAIN.label, entity = EntityEnum.RACE.name, description = RaceEnum.ELFE_SYLVAIN.description, history = RaceEnum.ELFE_SYLVAIN.history),
                Info(id = null, name = RaceEnum.HAUT_ELFE.label, entity = EntityEnum.RACE.name, description = RaceEnum.HAUT_ELFE.description, history = RaceEnum.HAUT_ELFE.history),
                Info(id = null, name = RaceEnum.GNOME.label, entity = EntityEnum.RACE.name, description = RaceEnum.GNOME.description, history = RaceEnum.GNOME.history),
                Info(id = null, name = RaceEnum.HUMAIN.label, entity = EntityEnum.RACE.name, description = RaceEnum.HUMAIN.description, history = RaceEnum.HUMAIN.history),
                Info(id = null, name = RaceEnum.NAIN.label, entity = EntityEnum.RACE.name, description = RaceEnum.NAIN.description, history = RaceEnum.NAIN.history),

                Info(id = null, name = ClasseEnum.BARBARE.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.BARBARE.description, history = ClasseEnum.BARBARE.history),
                Info(id = null, name = ClasseEnum.BARDE.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.BARDE.description, history = ClasseEnum.BARDE.history),
                Info(id = null, name = ClasseEnum.CHEVALIER.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.CHEVALIER.description, history = ClasseEnum.CHEVALIER.history),
                Info(id = null, name = ClasseEnum.DRUIDE.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.DRUIDE.description, history = ClasseEnum.DRUIDE.history),
                Info(id = null, name = ClasseEnum.GUERRIER.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.GUERRIER.description, history = ClasseEnum.GUERRIER.history),
                Info(id = null, name = ClasseEnum.INGENIEUR.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.INGENIEUR.description, history = ClasseEnum.INGENIEUR.history),
                Info(id = null, name = ClasseEnum.MAGICIEN.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.MAGICIEN.description, history = ClasseEnum.MAGICIEN.history),
                Info(id = null, name = ClasseEnum.MOINE.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.MOINE.description, history = ClasseEnum.MOINE.history),
                Info(id = null, name = ClasseEnum.NECROMANCIEN.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.NECROMANCIEN.description, history = ClasseEnum.NECROMANCIEN.history),
                Info(id = null, name = ClasseEnum.PRETRE.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.PRETRE.description, history = ClasseEnum.PRETRE.history),
                Info(id = null, name = ClasseEnum.RODEUR.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.RODEUR.description, history = ClasseEnum.RODEUR.history),
                Info(id = null, name = ClasseEnum.VOLEUR.label, entity = EntityEnum.CLASSE.name, description = ClasseEnum.VOLEUR.description, history = ClasseEnum.VOLEUR.history),


                Info(id = null, name = VoieEnum.VOIE_DE_L_ARTILLERIE.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DE_L_ARTILLERIE.description, history = VoieEnum.VOIE_DE_L_ARTILLERIE.history),
                Info(id = null, name = RangEnum.RANG_1_ARTILLERIE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_ARTILLERIE.description, history = RangEnum.RANG_1_ARTILLERIE.history),
                Info(id = null, name = RangEnum.RANG_2_ARTILLERIE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_ARTILLERIE.description, history = RangEnum.RANG_2_ARTILLERIE.history),
                Info(id = null, name = RangEnum.RANG_3_ARTILLERIE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_ARTILLERIE.description, history = RangEnum.RANG_3_ARTILLERIE.history),
                Info(id = null, name = RangEnum.RANG_4_ARTILLERIE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_ARTILLERIE.description, history = RangEnum.RANG_4_ARTILLERIE.history),
                Info(id = null, name = RangEnum.RANG_5_ARTILLERIE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_ARTILLERIE.description, history = RangEnum.RANG_5_ARTILLERIE.history),

                Info(id = null, name = VoieEnum.VOIE_DU_CHIMISTE.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DU_CHIMISTE.description, history = VoieEnum.VOIE_DU_CHIMISTE.history),
                Info(id = null, name = RangEnum.RANG_1_CHIMISTE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_CHIMISTE.description, history = RangEnum.RANG_1_CHIMISTE.history),
                Info(id = null, name = RangEnum.RANG_2_CHIMISTE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_CHIMISTE.description, history = RangEnum.RANG_2_CHIMISTE.history),
                Info(id = null, name = RangEnum.RANG_3_CHIMISTE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_CHIMISTE.description, history = RangEnum.RANG_3_CHIMISTE.history),
                Info(id = null, name = RangEnum.RANG_4_CHIMISTE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_CHIMISTE.description, history = RangEnum.RANG_4_CHIMISTE.history),
                Info(id = null, name = RangEnum.RANG_5_CHIMISTE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_CHIMISTE.description, history = RangEnum.RANG_5_CHIMISTE.history),

                Info(id = null, name = VoieEnum.VOIE_DU_TIREUR.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DU_TIREUR.description, history = VoieEnum.VOIE_DU_TIREUR.history),
                Info(id = null, name = RangEnum.RANG_1_TIREUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_TIREUR.description, history = RangEnum.RANG_1_TIREUR.history),
                Info(id = null, name = RangEnum.RANG_2_TIREUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_TIREUR.description, history = RangEnum.RANG_2_TIREUR.history),
                Info(id = null, name = RangEnum.RANG_3_TIREUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_TIREUR.description, history = RangEnum.RANG_3_TIREUR.history),
                Info(id = null, name = RangEnum.RANG_4_TIREUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_TIREUR.description, history = RangEnum.RANG_4_TIREUR.history),
                Info(id = null, name = RangEnum.RANG_5_TIREUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_TIREUR.description, history = RangEnum.RANG_5_TIREUR.history),

                Info(id = null, name = VoieEnum.VOIE_DE_LA_MECANIQUE.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DE_LA_MECANIQUE.description, history = VoieEnum.VOIE_DE_LA_MECANIQUE.history),
                Info(id = null, name = RangEnum.RANG_1_MECANIQUE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_MECANIQUE.description, history = RangEnum.RANG_1_MECANIQUE.history),
                Info(id = null, name = RangEnum.RANG_2_MECANIQUE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_MECANIQUE.description, history = RangEnum.RANG_2_MECANIQUE.history),
                Info(id = null, name = RangEnum.RANG_3_MECANIQUE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_MECANIQUE.description, history = RangEnum.RANG_3_MECANIQUE.history),
                Info(id = null, name = RangEnum.RANG_4_MECANIQUE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_MECANIQUE.description, history = RangEnum.RANG_4_MECANIQUE.history),
                Info(id = null, name = RangEnum.RANG_5_MECANIQUE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_MECANIQUE.description, history = RangEnum.RANG_5_MECANIQUE.history),


                Info(id = null, name = VoieEnum.VOIE_BESTIALE.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_BESTIALE.description, history = VoieEnum.VOIE_BESTIALE.history),
                Info(id = null, name = RangEnum.RANG_1_BESTIALE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_BESTIALE.description, history = RangEnum.RANG_1_BESTIALE.history),
                Info(id = null, name = RangEnum.RANG_2_BESTIALE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_BESTIALE.description, history = RangEnum.RANG_2_BESTIALE.history),
                Info(id = null, name = RangEnum.RANG_3_BESTIALE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_BESTIALE.description, history = RangEnum.RANG_3_BESTIALE.history),
                Info(id = null, name = RangEnum.RANG_4_BESTIALE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_BESTIALE.description, history = RangEnum.RANG_4_BESTIALE.history),
                Info(id = null, name = RangEnum.RANG_5_BESTIALE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_BESTIALE.description, history = RangEnum.RANG_5_BESTIALE.history),

                Info(id = null, name = VoieEnum.VOIE_DU_PROTECTEUR.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DU_PROTECTEUR.description, history = VoieEnum.VOIE_DU_PROTECTEUR.history),
                Info(id = null, name = RangEnum.RANG_1_PROTECTEUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_PROTECTEUR.description, history = RangEnum.RANG_1_PROTECTEUR.history),
                Info(id = null, name = RangEnum.RANG_2_PROTECTEUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_PROTECTEUR.description, history = RangEnum.RANG_2_PROTECTEUR.history),
                Info(id = null, name = RangEnum.RANG_3_PROTECTEUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_PROTECTEUR.description, history = RangEnum.RANG_3_PROTECTEUR.history),
                Info(id = null, name = RangEnum.RANG_4_PROTECTEUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_PROTECTEUR.description, history = RangEnum.RANG_4_PROTECTEUR.history),
                Info(id = null, name = RangEnum.RANG_5_PROTECTEUR.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_PROTECTEUR.description, history = RangEnum.RANG_5_PROTECTEUR.history),

                Info(id = null, name = VoieEnum.VOIE_DE_LA_NATURE.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DE_LA_NATURE.description, history = VoieEnum.VOIE_DE_LA_NATURE.history),
                Info(id = null, name = RangEnum.RANG_1_NATURE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_NATURE.description, history = RangEnum.RANG_1_NATURE.history),
                Info(id = null, name = RangEnum.RANG_2_NATURE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_NATURE.description, history = RangEnum.RANG_2_NATURE.history),
                Info(id = null, name = RangEnum.RANG_3_NATURE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_NATURE.description, history = RangEnum.RANG_3_NATURE.history),
                Info(id = null, name = RangEnum.RANG_4_NATURE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_NATURE.description, history = RangEnum.RANG_4_NATURE.history),
                Info(id = null, name = RangEnum.RANG_5_NATURE.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_NATURE.description, history = RangEnum.RANG_5_NATURE.history),

                Info(id = null, name = VoieEnum.VOIE_DES_VEGETAUX.label, entity = EntityEnum.VOIE.name, description = VoieEnum.VOIE_DES_VEGETAUX.description, history = VoieEnum.VOIE_DES_VEGETAUX.history),
                Info(id = null, name = RangEnum.RANG_1_VEGETAUX.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_1_VEGETAUX.description, history = RangEnum.RANG_1_VEGETAUX.history),
                Info(id = null, name = RangEnum.RANG_2_VEGETAUX.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_2_VEGETAUX.description, history = RangEnum.RANG_2_VEGETAUX.history),
                Info(id = null, name = RangEnum.RANG_3_VEGETAUX.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_3_VEGETAUX.description, history = RangEnum.RANG_3_VEGETAUX.history),
                Info(id = null, name = RangEnum.RANG_4_VEGETAUX.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_4_VEGETAUX.description, history = RangEnum.RANG_4_VEGETAUX.history),
                Info(id = null, name = RangEnum.RANG_5_VEGETAUX.label, entity = EntityEnum.RANG.name, description = RangEnum.RANG_5_VEGETAUX.description, history = RangEnum.RANG_5_VEGETAUX.history),

                )
        }
    }
}