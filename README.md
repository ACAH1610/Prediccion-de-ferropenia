# Predicción estado de ferropenia WebApp 

La web app de predicción del estado de ferropenia es una interfaz que integra un modelo de machine learning para realizar la clasificación de pacientes pediátricos en ferropenia latente o funcional, anemia ferropénica o ausencia de ferropenia.

Para este proyecto se han utilizado datos de la población del Hospital Universitario Infantil Niño Jesús. 


## Utilizar la appweb

Se puede acceder a la app web a través del siguiente enlace:
 [link](https://andreaatuncarhuaman.shinyapps.io/prediccion_ferropenia/)


## Resumen
El déficit de hierro (DH) es causante de la mitad de todas las anemias que afectan a una cuarta parte de la población mundial, diferenciándose 3 estadios:  ferropenia latente, ferropenia funcional y anemia ferropénica. Aún así, los signos y síntomas clínicos de la anemia por DH suelen pasarse por alto.
Por ello, se propone realizar un modelo capaz de predecir, con los valores de la serie roja del hemograma, la edad y sexo del paciente, si presenta ferropenia latente o funcional y así anticipar la caída de la hemoglobina; o en caso de anemia, diferenciar si corresponde con anemia ferropénica u otra patología que no conlleve DH.
Para ello se lleva a cabo la recopilación de datos, exploración de los mismos y preprocesamiento, entrenamiento del modelo con distintos algoritmos de clasificación, evaluación del rendimiento con diferentes métricas y mejora del modelo.
Los mejores resultados se obtuvieron con la validación 10-fold-crossvalidation, balanceando los datos con la técnica SMOTE y con los parámetros de tuning grid por defecto del paquete caret.
El mejor modelo ha sido Random forest con una sensibilidad de 76,1%, especificidad de 87,5%, precisión de 79,4% y exactitud de 81.2%, con el que se acortarían tiempos para instaurar el tratamiento adecuado y se podrían reducir costes en el laboratorio.
La implementación de este modelo en una aplicación web supone una herramienta útil para apoyar a los profesionales sanitarios.



## Lenguajes de programación

RStudio: entorno de trabajo que utiliza el lenguaje de programación R. La versión utilizada es la 4.3.3. En este entorno se utilizarán distintas librerías entre las que destacan caret para la creación de modelos y Shiny para la creación de la aplicación web.



