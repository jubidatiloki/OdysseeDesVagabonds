package fr.btytgat.odysseedesvagabonds

import android.os.Bundle
import android.view.Menu
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.MenuCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.navigateUp
import androidx.navigation.ui.setupActionBarWithNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.navigation.NavigationView
import fr.btytgat.odysseedesvagabonds.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var appBarConfiguration: AppBarConfiguration
    private lateinit var binding: ActivityMainBinding



    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setSupportActionBar(binding.appBarMain.toolbar)

        val drawerLayout: DrawerLayout = binding.drawerLayout
        val navView: NavigationView = binding.navView
        val navController = findNavController(R.id.nav_host_fragment_content_main)
        // Passing each menu ID as a set of Ids because each
        // menu should be considered as top level destinations.
        appBarConfiguration = AppBarConfiguration(
            setOf(
                R.id.nav_home, R.id.nav_character, R.id.nav_classe, R.id.nav_race, R.id.nav_dice
            ), drawerLayout
        )
        setupActionBarWithNavController(navController, appBarConfiguration)
        navView.setupWithNavController(navController)

//        val databaseManager = DatabaseManager.getInstance(this)
//        if(databaseManager.classeDao().getAllClasses().isEmpty()) {
//            DatabaseUtils.initDatabase(databaseManager)
//        }
//        val classeManager = ClasseManager(this)
//        val classes = classeManager.loadClasses()
//
//        Log.i("database", "classes size = " + classes.size)
//        classes.forEach {
//            Log.i("database", "classe = ${it.info?.name} - ${it.voies}")
//        }
//
//        val infos = databaseManager.infoDao().getAllInfos();
//        Log.i("database", "infos size = " + infos.size)
//        infos.forEach {
//            Log.i("database", "info = $it")
//        }
    }



    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        MenuCompat.setGroupDividerEnabled(menu, true)
        menuInflater.inflate(R.menu.main, menu)
        return true
    }

    override fun onSupportNavigateUp(): Boolean {
        val navController = findNavController(R.id.nav_host_fragment_content_main)
        return navController.navigateUp(appBarConfiguration) || super.onSupportNavigateUp()
    }
}