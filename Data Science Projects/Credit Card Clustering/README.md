# Segmentación de Clientes de Tarjetas de Crédito

## Descripción

Este proyecto utiliza técnicas de aprendizaje no supervisado para realizar una segmentación de clientes de tarjetas de crédito. Se emplean algoritmos de clustering para identificar distintos grupos de clientes basados en sus patrones de gasto y comportamiento financiero. El objetivo es proporcionar información valiosa para optimizar estrategias de marketing y mejorar la personalización de los servicios financieros.

---

## Contenido del Proyecto

El análisis incluye las siguientes etapas:

1. **Carga y preprocesamiento de datos**: Limpieza y transformación de datos para su correcta utilización en los modelos de clustering.    
2. **Análisis exploratorio de datos (EDA)**: Visualización y análisis de distribuciones de variables relevantes.
3. **Aplicación de algoritmos de clustering**: Uso de K-Means, así como la validación de los clusters usando las métricas como Inertia, Silhouette, Davies-Boulding y Calinski-Harabasz.
4. **Evaluación de resultados**: Análisis de las características de cada cluster y su interpretación.
5. **Conclusiones y recomendaciones**: Síntesis de hallazgos y sugerencias para aplicaciones comerciales.

---
## Objetivo del Proyecto

El objetivo principal de este análisis es segmentar a los clientes de tarjetas de crédito en grupos significativos con base en su comportamiento financiero, y describir cada grupo para facilitar la toma de decisiones estratégicas dentro del negocio.

---

## Resultados y Conclusiones

El análisis de clustering permitió segmentar a los clientes en 6 diferentes grupos según su cantidad de saldo, total de compras, adelantos en efectivo, límite de crédito, cantidad de pagos y monto mínimo de pago. Los clusters quedaron de la siguiente manera:

| Cluster | Descripción                                                                                     |
| :-----: | ----------------------------------------------------------------------------------------------- |
|    0    | Clientes dependientes del efectivo                                                              |
|    1    | Clientes de bajo uso: Compras, balance y efectivo utilizados muy bajos. *Perfil poco atractivo* |
|    2    | Clientes intensivos en efectivo                                                                 |
|    3    | Clientes con mayor cantidad de saldo y pagos equilibrados                                       |
|    4    | Clientes con mayor pago mínimo. Compras relativamente altas, pero crédito limitado.             |
|    5    | Clientes compradores frecuentes. *Perfil valioso*                                               |

Debido a las características, el perfil más atractivo son aquellos que entran dentro del cluster 5, debido a que estos clientes:

- Tienen mayor volumen de compras
- Uso de efectivo bajo.
- Hacen muchos pagos, probablemente mantienen una buena relación con su crédito.

---

## Áreas de mejora

- **Comparación con otros algoritmos**: Evaluar el desempeño de modelos alternativos como DBSCAN, clustering jerárquico o Gaussian Mixture Models para validar o mejorar la segmentación actual.
- **Análisis más profundo de los perfiles**: Incorporar nuevas métricas o explorar relaciones entre variables que permitan caracterizar con mayor detalle a cada grupo.
- **Implementación de recomendaciones accionables**: Traducir los resultados en estrategias concretas de retención, fidelización o personalización de productos financieros por tipo de cliente.