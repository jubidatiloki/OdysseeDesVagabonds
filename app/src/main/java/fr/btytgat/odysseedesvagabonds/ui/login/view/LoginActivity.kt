package fr.btytgat.odysseedesvagabonds.ui.login.view

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatEditText
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.home.view.HomeActivity

class LoginActivity: AppCompatActivity() {

    private val TAG = "LoginActivity"

    private lateinit var auth: FirebaseAuth

    private lateinit var etLogin: AppCompatEditText
    private lateinit var etPassword: AppCompatEditText
    private lateinit var btSignIn: AppCompatButton
    private lateinit var tvSignUp: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_login)

        auth = Firebase.auth

        etLogin = findViewById(R.id.et_login)
        etPassword = findViewById(R.id.et_password)
        btSignIn = findViewById(R.id.bt_sign_in)
        tvSignUp = findViewById(R.id.tv_sign_up)

        btSignIn.setOnClickListener {
            signIn(etLogin.text.toString(), etPassword.text.toString())
        }
        tvSignUp.setOnClickListener {
            signUp(etLogin.text.toString(), etPassword.text.toString())
        }
    }

    override fun onStart() {
        super.onStart()
        val currentUser = auth.currentUser
        if(currentUser != null){
            startActivity(Intent(this, HomeActivity::class.java))
        }
    }


    private fun signUp(login: String, password: String){
        auth.createUserWithEmailAndPassword(login, password)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    // Sign in success, update UI with the signed-in user's information
                    Log.d(TAG, "createUserWithEmail:success")
                    val user = auth.currentUser
//                    updateUI(user)
                    startActivity(Intent(this, HomeActivity::class.java))
                } else {
                    // If sign in fails, display a message to the user.
                    Log.w(TAG, "createUserWithEmail:failure", task.exception)
                    Toast.makeText(baseContext, "Authentication failed.",
                        Toast.LENGTH_SHORT).show()
//                    updateUI(null)
                }
            }
    }

    private fun signIn(login: String, password: String){
        auth.signInWithEmailAndPassword(login, password)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    // Sign in success, update UI with the signed-in user's information
                    Log.d(TAG, "signInWithEmail:success")
                    val user = auth.currentUser
//                    updateUI(user)
                    startActivity(Intent(this, HomeActivity::class.java))

                } else {
                    // If sign in fails, display a message to the user.
                    Log.w(TAG, "signInWithEmail:failure", task.exception)
                    Toast.makeText(baseContext, "Authentication failed.",
                        Toast.LENGTH_SHORT).show()
//                    updateUI(null)
                }
            }
    }
}