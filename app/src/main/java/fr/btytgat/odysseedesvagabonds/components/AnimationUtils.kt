package fr.btytgat.odysseedesvagabonds.components

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.view.View
import android.view.animation.AccelerateInterpolator

class AnimationUtils {

    companion object {
        open fun buttonAnimation (view: View) {
            val start = 1.0f
            val mid = 0.9f
            val end = 1f

            val animationSet = AnimatorSet()

            val scaleX = ObjectAnimator.ofFloat(view, View.SCALE_X, start, mid)
            val scaleY = ObjectAnimator.ofFloat(view, View.SCALE_Y, start, mid)
            val translationZ = ObjectAnimator.ofFloat(view, View.TRANSLATION_Z, start, mid)

            val set1 = AnimatorSet()
            set1.playTogether(scaleX, scaleY, translationZ)
            set1.duration = 100
            set1.interpolator = AccelerateInterpolator()

            val scaleXBack = ObjectAnimator.ofFloat(view, View.SCALE_X, mid, end)
            val scaleYBack = ObjectAnimator.ofFloat(view, View.SCALE_Y, mid, end)
            val translationZBack = ObjectAnimator.ofFloat(view, View.TRANSLATION_Z, mid, end)

            val set2 = AnimatorSet()
            set2.playTogether(scaleXBack, scaleYBack, translationZBack)
            set2.duration = 100
            set2.interpolator = AccelerateInterpolator()

            animationSet.playSequentially(set1, set2)

            animationSet.start()
        }
    }
}