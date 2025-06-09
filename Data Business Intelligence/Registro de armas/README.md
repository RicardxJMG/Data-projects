# Registro de armas de fuego por diferentes motivos en México

Este proyecto analiza la cantidad de registros de armas de fuego en México durante los cuatro trimestres del año 2024. Se construyó un dashboard interactivo que permite explorar la distribución geográfica, el motivo de registro y las características de las armas registradas, con el objetivo de identificar patrones relevantes para el análisis social y de seguridad.

Los datos fueron recopilados por la [SEDENA](https://www.gob.mx/defensa) y son de libre uso. Pueden consultarse directamente [aquí](https://historico.datos.gob.mx/busca/dataset/armas-registradas-por-diferentes-motivos).

## Objetivos del proyecto

Este proyecto busca responder las siguientes preguntas:

1. *¿Qué entidades federativas concentran el mayor número de registros?*
2. *¿Cuál es el motivo de uso con mayor número de registros?*
3. *¿Qué tipo de arma tiene más registros?*

## Consideraciones

- Solo se incluyeron datos completos del año 2024, ya que los años anteriores tienen registros incompletos. Por ejemplo, solo contienen el conteo trimestral, pero no el  motivo de uso.
- El análisis está sujeto a actualizaciones conforme se publiquen nuevos datos.

## Herramientas utilizadas

- **Python**: Se utilizó la librería `pandas` para limpiar y convertir los archivos `.xlsx` a `.csv`, facilitando su análisis.
- **Power BI**: Para la construcción del dashboard interactivo.

## Dashboard

Las siguientes imágenes son una vista previa del dashboard.

![](./img/Pasted%20image%2020250609033330.png)

![](./img/Pasted%20image%2020250609033416.png)

Para poder interactuar con el dashboard clona esta carpeta de este repositorio con el siguiente comando:

```bash
git clone carpeta
```

Con este dashboard se pueden responder fácilmente las preguntas planteadas al inicio:

1. El Estado de México es la entidad federativa con mayor número de registros de armas durante 2024.
2. El personal militar activo representa el motivo con más registros en ese mismo año.
3. Las armas largas son las más registradas en el territorio mexicano durante 2024.

## Posibles mejoras

- Incorporar datos históricos si se liberan registros completos de años anteriores.
- Mejorar las visualizaciones para que sean más accesibles e intuitivas.
- Actualizar el dashboard con los datos del presente año (2025) para identificar nuevos patrones y extender el análisis.

## Contacto

Preguntas o sugerencias, contactarme por GitHub o al correo r.x.mg1801@gmail.com

















