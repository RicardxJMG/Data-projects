# Segmentación de Clientes Financieros con Machine Learning

## Resumen

Se segmentó a los clientes de tarjetas de crédito en **4 grupos** según su comportamiento financiero, usando PCA (6 componentes, más del 75% de la varianza explicada) y K-Means. Los grupos resultantes son:

- **Clientes básicos** (43.9%): saldo bajo, poca actividad de compra y alta dependencia de pagos mínimos.
- **Clientes responsables** (36.3%): alto volumen de compras, preferencia por compras a plazos y buen historial de pagos.
- **Altos saldos y adelantos** (15.6%): saldo alto, uso intensivo de adelantos de efectivo.
- **Clientes premium o destacados** (4.1%): compras de alto valor y excelente cumplimiento de pagos.

---

## Contexto y pregunta de negocio

El objetivo principal de este proyecto es segmentar a los clientes de tarjetas de crédito en grupos diferenciados basados en su comportamiento financiero, para facilitar decisiones estratégicas como campañas de marketing personalizadas, optimización de productos financieros y gestión de riesgos.

---

## Datos y diccionario

El análisis se realiza sobre datos de comportamiento de clientes de tarjetas de crédito.

---

## Metodología y decisiones

Se aplicaron técnicas de aprendizaje no supervisado en las siguientes etapas:

1. **Preprocesamiento**: corrección de valores inconsistentes y estandarización de las variables.
2. **Reducción de dimensionalidad con PCA**: se conservaron seis componentes principales, que explican más del 75% de la varianza.
3. **Segmentación con K-Means**: el número óptimo de clusters (4) se determinó con las métricas de validación Inertia, Silhouette Score, Davies-Bouldin Index y Calinski-Harabasz Score.

---

## Resultados

El análisis de clustering permitió segmentar a los clientes en 4 grupos según su comportamiento con el uso de tarjeta de crédito:

| Cluster | Tipo de cliente                     | Descripción                                                                                                                                     |
|:-------:|:------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------|
|    1    | Altos saldos y adelantos             | Saldo disponible alto, uso intensivo de adelantos de efectivo, pagos considerables. Representan el 15.6% del total de clientes.                  |
|    2    | Clientes responsables                | Alto volumen de compras, preferencia por compras a plazos, uso mínimo de adelantos y buen historial de pagos. Representan el 36.3%.              |
|    3    | Clientes básicos                     | Saldo disponible bajo, actividad de compra mínima, alta dependencia de pagos mínimos. Son el grupo mayoritario, representando el 43.9%.          |
|    4    | Clientes premium o destacados        | Segundo saldo más alto, alto volumen de compras de alto valor, excelente cumplimiento de pagos. Representan el 4.1% de los clientes.             |

---

## Limitaciones y siguientes pasos

### Limitaciones

- Con seis componentes principales se conserva más del 75% de la varianza explicada; el resto de la varianza no está representada en la segmentación.

### Siguientes pasos

- **Comparación con otros algoritmos**: evaluar el desempeño de modelos alternativos como DBSCAN, clustering jerárquico o Gaussian Mixture Models para validar o mejorar la segmentación actual.
- **Análisis más profundo de los perfiles**: incorporar nuevas métricas o explorar relaciones entre variables que permitan caracterizar con mayor detalle a cada grupo.
- **Implementación de recomendaciones accionables**: traducir los resultados en estrategias concretas de retención, fidelización o personalización de productos financieros por tipo de cliente.
