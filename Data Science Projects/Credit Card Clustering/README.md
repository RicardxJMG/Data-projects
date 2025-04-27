# Segmentación de Clientes de Tarjetas de Crédito

## Objetivo del Proyecto

El objetivo principal de este proyecto es segmentar a los clientes de tarjetas de crédito en grupos diferenciados basados en su comportamiento financiero, para facilitar decisiones estratégicas como campañas de marketing personalizadas, optimización de productos financieros y gestión de riesgos.

## Descripción

Este proyecto aplica técnicas de aprendizaje no supervisado para analizar el comportamiento de los clientes de tarjetas de crédito. Se realizaron varias etapas de preprocesamiento de los datos, incluyendo corrección de valores inconsistentes, estandarización y reducción de dimensionalidad mediante Análisis de Componentes Principales (PCA), conservando más del 75% de la varianza explicada con seis componentes principales.

Posteriormente, se aplicó el algoritmo K-Means para segmentar a los clientes en cuatro grupos distintos. El número óptimo de clusters se determinó utilizando métricas de validación como Inertia, Silhouette Score, Davies-Bouldin Index y Calinski-Harabasz Score.

---

## Resultados y Conclusiones

El análisis de clustering permitió segmentar a los clientes en 4 diferentes grupos según su comportamiento con el uso de tarjeta de crédito. Los clusters quedaron de la siguiente manera:

| Cluster | Tipo de cliente                     | Descripción                                                                                                                                     |
|:-------:|:------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------|
|    1    | Altos saldos y adelantos             | Saldo disponible alto, uso intensivo de adelantos de efectivo, pagos considerables. Representan el 15.6% del total de clientes.                  |
|    2    | Clientes responsables                | Alto volumen de compras, preferencia por compras a plazos, uso mínimo de adelantos y buen historial de pagos. Representan el 36.3%.              |
|    3    | Clientes básicos                     | Saldo disponible bajo, actividad de compra mínima, alta dependencia de pagos mínimos. Son el grupo mayoritario, representando el 43.9%.          |
|    4    | Clientes premium o destacados        | Segundo saldo más alto, alto volumen de compras de alto valor, excelente cumplimiento de pagos. Representan el 4.1% de los clientes.             |

---

## Áreas de mejora

- **Comparación con otros algoritmos**: Evaluar el desempeño de modelos alternativos como DBSCAN, clustering jerárquico o Gaussian Mixture Models para validar o mejorar la segmentación actual.
- **Análisis más profundo de los perfiles**: Incorporar nuevas métricas o explorar relaciones entre variables que permitan caracterizar con mayor detalle a cada grupo.
- **Implementación de recomendaciones accionables**: Traducir los resultados en estrategias concretas de retención, fidelización o personalización de productos financieros por tipo de cliente.
