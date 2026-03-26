# =============================================================================
# clustering_settings.py
# Segmentación de Clientes — German Credit Data
#
# Modelos: KMeans & DBSCAN
# Pipelines:
#   - Pipeline 1: PCA sobre variables numéricas
#   - Pipeline 2: PCA sobre todo el espacio preprocesado
# =============================================================================

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

from typing import Tuple, List, Optional, Dict, Any
from .configs import (
    build_cat_preprocessor, build_num_preprocessor, SEED,
    num_attributes, ordinal_categories, ordinal_attributes, onehot_attributes
)


from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import  StandardScaler
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans, DBSCAN
from sklearn.metrics import (
    silhouette_score,
    calinski_harabasz_score,
    davies_bouldin_score,
    adjusted_rand_score,
    normalized_mutual_info_score
)



# =============================================================================
# 3. PIPELINES DE CLUSTERING
# =============================================================================

def build_clustering_pipelines() -> Tuple[Pipeline, Pipeline]:
    """
    Construye y retorna los dos pipelines de preprocesamiento para clustering.

    Returns
    -------
    cl_pipe_1 : Pipeline — PCA aplicado solo a variables numéricas
    cl_pipe_2 : Pipeline — PCA aplicado a todo el espacio preprocesado
    """
    num_pipe_pca = build_num_preprocessor(num_attributes)
    num_pipe_pca[1].steps.append(('pca', PCA(n_components=.95)))

    num_pipe = build_num_preprocessor(num_attributes)

    cat_pipe = build_cat_preprocessor(
        ordinal_attributes=ordinal_attributes,
        onehot_attributes=onehot_attributes,
        ordinal_categories=ordinal_categories,
    )

    preprocessor_numpca = ColumnTransformer(
        transformers=[num_pipe_pca, *cat_pipe],
        remainder='drop',
        verbose_feature_names_out=False,
    )

    preprocessor_normal = ColumnTransformer(
        transformers=[num_pipe, *cat_pipe],
        remainder='drop',
        verbose_feature_names_out=False,
    )

    cl_pipe_1 = Pipeline(steps=[('preprocessor', preprocessor_numpca)])

    cl_pipe_2 = Pipeline(steps=[
        ('preprocessor', preprocessor_normal),
        ('scaler',       StandardScaler()),
        ('pca',          PCA(n_components=.95)),
    ])

    return cl_pipe_1, cl_pipe_2


# =============================================================================
# 4. BÚSQUEDA DE K ÓPTIMO — KMeans
# =============================================================================

def search_optimal_k(X: np.ndarray, k_range: Tuple[int, int] = (2, 11), random_state: int = SEED) -> pd.DataFrame:
    """
    Evalúa KMeans para cada K en el rango dado con tres métricas internas
    y genera gráfico de curvas.

    Parameters
    ----------
    X           : array-like, datos transformados
    k_range     : tupla (k_min, k_max), rango de K a evaluar
    random_state: semilla de aleatoriedad

    Returns
    -------
    df : DataFrame con métricas por K
    """
    k_min, k_max = k_range
    results  = []

    for k in range(k_min, k_max):
        km = KMeans(n_clusters=k, random_state=random_state, n_init='auto')
        labels = km.fit_predict(X)
        results.append({
            'K':                  k,
            'Inercia':            km.inertia_,
            'Silhouette':         silhouette_score(X, labels),
            'Calinski-Harabasz':  calinski_harabasz_score(X, labels),
            'Davies-Bouldin':     davies_bouldin_score(X, labels),
        })

    df = pd.DataFrame(results).set_index('K')
    k_values = list(df.index)

    fig, axes = plt.subplots(2, 2, figsize=(14, 9))
    fig.suptitle('Búsqueda de K óptimo — KMeans', fontsize=15, fontweight='bold')

    metrics = [
        ('Inercia',           'Elbow Method',      'steelblue',  False),
        ('Silhouette',        'Silhouette Score',   'darkorange', True),
        ('Calinski-Harabasz', 'Calinski-Harabasz',  'seagreen',   True),
        ('Davies-Bouldin',    'Davies-Bouldin',      'crimson',    False),
    ]

    for ax, (col, title, color, greater) in zip(axes.flatten(), metrics):
        ax.plot(k_values, df[col].values, marker='o', color=color, linewidth=2)
        ax.set_xticks(k_values)
        ax.set_xlim(k_values[0] - 0.5, k_values[-1] + 0.5)
        ax.axvline(x=k_min, color='gray', linestyle='--', alpha=0.6,
                   label=f'K={k_min} (hipótesis)')
        optim = df[col].idxmax() if greater else df[col].idxmin()
        ax.axvline(x=optim, color=color, linestyle=':', alpha=0.8,
                   label=f'K óptimo={optim}')
        ax.set_title(title, fontweight='bold')
        ax.set_xlabel('Número de clusters (K)')
        ax.set_ylabel(col)
        ax.legend(fontsize=8)
        ax.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('kmeans_k_selection.png', dpi=150, bbox_inches='tight')
    plt.show()

    return df


# =============================================================================
# 5. BÚSQUEDA DE HIPERPARÁMETROS — DBSCAN
# =============================================================================

def search_dbscan_params(X_transformed: np.ndarray, eps_range: Optional[np.ndarray] = None, min_samples_range: Optional[range] = None) -> Tuple[Optional[pd.Series], pd.DataFrame]:
    """
    Grid search manual sobre eps y min_samples para DBSCAN.
    Solo evalúa configuraciones con 2–10 clusters y < 30% de ruido.
    Genera heatmap de Silhouette score.

    Returns
    -------
    best : Series con la mejor configuración (por Silhouette)
    df   : DataFrame completo de configuraciones válidas
    """
    if eps_range is None:
        eps_range = np.round(np.linspace(0.3, 2.0, 15), 2)
    if min_samples_range is None:
        min_samples_range = range(3, 15)

    results = []

    for eps in eps_range:
        for ms in min_samples_range:
            db     = DBSCAN(eps=eps, min_samples=ms)
            labels = db.fit_predict(X_transformed)

            n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
            n_noise    = np.sum(labels == -1)
            pct_noise  = n_noise / len(labels)

            if n_clusters < 2 or n_clusters > 10 or pct_noise > 0.30:
                continue

            mask = labels != -1
            if mask.sum() < 2:
                continue

            results.append({
                'eps':               eps,
                'min_samples':       ms,
                'n_clusters':        n_clusters,
                'pct_noise':         round(pct_noise, 3),
                'Silhouette':        round(silhouette_score(X_transformed[mask], labels[mask]), 4),
                'Calinski-Harabasz': round(calinski_harabasz_score(X_transformed[mask], labels[mask]), 2),
                'Davies-Bouldin':    round(davies_bouldin_score(X_transformed[mask], labels[mask]), 4),
            })

    if not results:
        print("No se encontraron configuraciones DBSCAN válidas. "
              "Prueba ampliar eps_range o min_samples_range.")
        return None, pd.DataFrame()

    df   = pd.DataFrame(results)
    best = df.loc[df['Silhouette'].idxmax()]

    pivot = df.pivot_table(values='Silhouette', index='min_samples', columns='eps')
    fig, ax = plt.subplots(figsize=(12, 5))
    im = ax.imshow(pivot.values, aspect='auto', cmap='YlOrRd', origin='lower')
    ax.set_xticks(range(len(pivot.columns)))
    ax.set_xticklabels(pivot.columns, rotation=45, fontsize=7)
    ax.set_yticks(range(len(pivot.index)))
    ax.set_yticklabels(pivot.index, fontsize=7)
    ax.set_xlabel('eps')
    ax.set_ylabel('min_samples')
    ax.set_title('DBSCAN — Silhouette Score (configs válidas)', fontweight='bold')
    plt.colorbar(im, ax=ax, label='Silhouette')
    plt.tight_layout()
    plt.savefig('dbscan_heatmap.png', dpi=150, bbox_inches='tight')
    plt.show()

    print(f"\nMejor configuración DBSCAN (por Silhouette):\n{best.to_string()}")
    return best, df


# =============================================================================
# 6. EVALUACIÓN DE MODELOS
# =============================================================================

def model_evaluation(model_name: str, labels: np.ndarray, X_transformed: np.ndarray, y_true: Optional[np.ndarray] = None) -> Dict[str, Any]:
    """
    Calcula métricas internas y, opcionalmente, métricas externas vs etiqueta real.

    Parameters
    ----------
    model_name     : str, nombre identificador del experimento
    labels         : array de etiquetas asignadas por el modelo
    X_transformed  : array de datos transformados
    y_true         : array de etiquetas reales (opcional)

    Returns
    -------
    dict con métricas del modelo
    """
    mask      = labels != -1
    n_clusters = len(set(labels[mask]))
    n_noise    = np.sum(labels == -1)

    result = {
        'Modelo':    model_name,
        'N Clusters': n_clusters,
        'N Ruido':    n_noise,
    }

    if n_clusters >= 2 and mask.sum() > 1:
        result['Silhouette']        = round(silhouette_score(X_transformed[mask], labels[mask]), 4)
        result['Calinski-Harabasz'] = round(calinski_harabasz_score(X_transformed[mask], labels[mask]), 2)
        result['Davies-Bouldin']    = round(davies_bouldin_score(X_transformed[mask], labels[mask]), 4)
    else:
        result.update({'Silhouette': np.nan, 'Calinski-Harabasz': np.nan, 'Davies-Bouldin': np.nan})

    if y_true is not None:
        result['ARI'] = round(adjusted_rand_score(y_true[mask], labels[mask]), 4)
        result['NMI'] = round(normalized_mutual_info_score(y_true[mask], labels[mask]), 4)

    return result


# =============================================================================
# 7. VISUALIZACIÓN 2D
# =============================================================================

def clusters_visualization_2d(experiments: List[Tuple[str, np.ndarray, np.ndarray]], y_true: Optional[np.ndarray] = None, random_state: int = SEED) -> None:
    """
    Para cada experimento (nombre, X_transformed, labels) genera dos paneles:
      - Izquierdo: clusters asignados por el modelo
      - Derecho:   etiqueta real (si se proporciona)

    Parameters
    ----------
    experiments : lista de tuplas (nombre, X_transformed, labels)
    y_true      : array de etiquetas reales (opcional)
    random_state: semilla para PCA 2D
    """
    n_exp  = len(experiments)
    n_cols = 2 if y_true is not None else 1
    fig    = plt.figure(figsize=(7 * n_cols, 5 * n_exp))
    gs     = gridspec.GridSpec(n_exp, n_cols, figure=fig, hspace=0.4, wspace=0.3)

    pca2d = PCA(n_components=2, random_state=random_state)

    for i, (name, X_tr, labels) in enumerate(experiments):
        X2d = pca2d.fit_transform(X_tr)

        ax_cl = fig.add_subplot(gs[i, 0])
        unique_labels = sorted(set(labels))
        cmap_cl = plt.cm.get_cmap('tab10', len(unique_labels))

        for j, lbl in enumerate(unique_labels):
            mask  = labels == lbl
            color = 'lightgray' if lbl == -1 else cmap_cl(j)
            label = 'Ruido'       if lbl == -1 else f'Cluster {lbl}'
            ax_cl.scatter(X2d[mask, 0], X2d[mask, 1], c=[color], s=10, alpha=0.6, label=label)

        ax_cl.set_title(f'{name}\nClusters del modelo', fontweight='bold', fontsize=10)
        ax_cl.set_xlabel('PC1')
        ax_cl.set_ylabel('PC2')
        ax_cl.legend(markerscale=2, fontsize=8, loc='best')
        ax_cl.grid(alpha=0.2)

        if y_true is not None:
            ax_gt = fig.add_subplot(gs[i, 1])
            colors_gt = {0: '#2ecc71', 1: '#e74c3c'}
            labels_gt = {0: 'Buen cliente (0)', 1: 'Mal cliente (1)'}

            for gt_lbl, gt_color in colors_gt.items():
                mask_gt = y_true == gt_lbl
                ax_gt.scatter(X2d[mask_gt, 0], X2d[mask_gt, 1],
                              c=gt_color, s=10, alpha=0.6, label=labels_gt[gt_lbl])

            ax_gt.set_title(f'{name}\nEtiqueta real (Ground Truth)', fontweight='bold', fontsize=10)
            ax_gt.set_xlabel('PC1')
            ax_gt.set_ylabel('PC2')
            ax_gt.legend(markerscale=2, fontsize=8)
            ax_gt.grid(alpha=0.2)

    fig.suptitle('Visualización 2D de Clusters — Proyección PCA',
                 fontsize=14, fontweight='bold', y=1.01)
    plt.savefig('clusters_2d.png', dpi=150, bbox_inches='tight')
    plt.show()
