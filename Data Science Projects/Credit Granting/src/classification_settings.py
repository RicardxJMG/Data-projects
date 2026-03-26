# =============================================================================
# classification_settings.py
# Clasificación Supervisada de Clientes — German Credit Data
#
# Modelos: Regresión Logística & Random Forest
# Criterio de optimización: Recall (minimizar falsos negativos — malos clientes)
# Función de pérdida: FP × 1 + FN × 5
# =============================================================================

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

from typing import List, Tuple, Optional, Dict, Any

from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import  GridSearchCV, cross_validate
from sklearn.metrics import (
    accuracy_score, recall_score, f1_score, precision_score,
    roc_auc_score, confusion_matrix, ConfusionMatrixDisplay,
    RocCurveDisplay, PrecisionRecallDisplay,
)

# Importa constructores de preprocesamiento desde el módulo de clustering
from .configs import (
    build_num_preprocessor,
    build_cat_preprocessor,
    num_attributes, ordinal_attributes, onehot_attributes, ordinal_categories,
    SEED
)


# =============================================================================
# 1. PIPELINES DE CLASIFICACIÓN
# =============================================================================

def build_classification_pipelines() -> Tuple[Pipeline, Pipeline, Pipeline, Pipeline]:
    """
    Construye los cuatro pipelines de clasificación:
      - logistic_pipe1 / rforest_pipe1: Pipeline 1 (PCA numérico)
      - logistic_pipe2 / rforest_pipe2: Pipeline 2 (PCA general)

    Returns
    -------
    logistic_pipe1, logistic_pipe2, rforest_pipe1, rforest_pipe2
    """
    num_pipe_pca = build_num_preprocessor(num_attributes)
    num_pipe_pca[1].steps.append(('pca', PCA(n_components=.95)))

    num_pipe = build_num_preprocessor(num_attributes)

    cat_pipe = build_cat_preprocessor(
        ordinal_attributes=ordinal_attributes,
        onehot_attributes=onehot_attributes,
        ordinal_categories=ordinal_categories,    )

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

    reg_pipe1 = Pipeline(steps=[('preprocessor', preprocessor_numpca)])

    reg_pipe2 = Pipeline(steps=[
        ('preprocessor', preprocessor_normal),
        ('scaler',       StandardScaler()),
        ('pca',          PCA(n_components=.95)),
    ])

    logistic_pipe1 = Pipeline(steps=[
        ('data_transformer_pcanum',    reg_pipe1),
        ('logistic', LogisticRegression(random_state=SEED)),
    ])

    logistic_pipe2 = Pipeline(steps=[
        ('data_transformer_pcageneral', reg_pipe2),
        ('logistic', LogisticRegression(random_state=SEED)),
    ])

    rforest_pipe1 = Pipeline(steps=[
        ('data_transfomer_pcanum',    reg_pipe1),
        ('rforest', RandomForestClassifier(random_state=SEED)),
    ])

    rforest_pipe2 = Pipeline(steps=[
        ('data_transfomer_pcageneral', reg_pipe2),
        ('rforest', RandomForestClassifier(random_state=SEED)),
    ])

    return logistic_pipe1, logistic_pipe2, rforest_pipe1, rforest_pipe2


# =============================================================================
# 2. GRID SEARCH — Random Forest (optimiza Recall)
# =============================================================================

def run_grid_search(rforest_pipe1: Pipeline, rforest_pipe2: Pipeline, X_train: np.ndarray, y_train: np.ndarray, cv: Any) -> Tuple[GridSearchCV, GridSearchCV]:
    """
    Ejecuta GridSearchCV sobre ambos pipelines de Random Forest
    optimizando Recall (detección de clientes malos).

    Returns
    -------
    grid_rf1, grid_rf2 : GridSearchCV entrenados con best_estimator_ disponible
    """
    param_grid = {
        'rforest__n_estimators': [100, 200, 300],
        'rforest__max_depth':    [2, 5, 10, 15, 20, 25, 30],
        'rforest__criterion':    ['gini', 'entropy', 'log_loss'],
    }

    print("=" * 60)
    print("GridSearchCV — Random Forest (scoring=recall)")

    grid_rf1 = GridSearchCV(
        estimator=rforest_pipe1, param_grid=param_grid,
        scoring='recall', cv=cv, n_jobs=-1, verbose=1, refit=True,
    )
    grid_rf2 = GridSearchCV(
        estimator=rforest_pipe2, param_grid=param_grid,
        scoring='recall', cv=cv, n_jobs=-1, verbose=1, refit=True,
    )

    print("\n[Pipeline 1 — PCA numérico]")
    grid_rf1.fit(X_train, y_train)
    print(f"  Mejores parámetros : {grid_rf1.best_params_}")
    print(f"  Mejor Recall (CV)  : {grid_rf1.best_score_:.4f}")

    print("\n[Pipeline 2 — PCA general]")
    grid_rf2.fit(X_train, y_train)
    print(f"  Mejores parámetros : {grid_rf2.best_params_}")
    print(f"  Mejor Recall (CV)  : {grid_rf2.best_score_:.4f}")

    return grid_rf1, grid_rf2


# =============================================================================
# 3. CROSS-VALIDATION
# =============================================================================

def summary_cv(cv_results: Dict[str, np.ndarray], name_model: str) -> Dict[str, Any]:
    """Convierte el dict de cross_validate en una fila de resumen."""
    return {
        'Modelo':     name_model,
        'Recall':     round(cv_results['test_recall'].mean(), 4),
        'Precision':  round(cv_results['test_precision'].mean(), 4),
        'F1':         round(cv_results['test_f1'].mean(), 4),
        'ROC-AUC':    round(cv_results['test_roc_auc'].mean(), 4),
        'Recall_std': round(cv_results['test_recall'].std(), 4),
    }


def run_cross_validation(pipelines_named: List[Tuple[str, Pipeline]], X_train: np.ndarray, y_train: np.ndarray, cv: Any) -> pd.DataFrame:
    """
    Ejecuta cross_validate para cada pipeline y retorna tabla comparativa.

    Parameters
    ----------
    pipelines_named : lista de tuplas (nombre, pipeline)
    X_train, y_train: datos de entrenamiento
    cv              : objeto de validación cruzada

    Returns
    -------
    df_cv : DataFrame con métricas promedio por modelo
    """
    cv_scoring = {
        'recall':    'recall',
        'precision': 'precision',
        'f1':        'f1',
        'roc_auc':   'roc_auc',
    }

    print("\n" + "=" * 60)
    print("Cross-Validation sobre X_train (5 folds estratificados)")

    resultados = []
    for name_model, pipe in pipelines_named:
        res = cross_validate(pipe, X_train, y_train, cv=cv, scoring=cv_scoring)
        resultados.append(summary_cv(res, name_model))

    df_cv = pd.DataFrame(resultados).set_index('Modelo')
    print("\nRESULTADOS CROSS-VALIDATION (media sobre 5 folds)")
    print(df_cv.to_string())
    print("\nNota: Recall_std indica estabilidad — valores altos sugieren sensibilidad al fold.")

    return df_cv


# =============================================================================
# 4. EVALUACIÓN POR UMBRAL
# =============================================================================

def threshold_evaluation(model: Any, name: str, X_test: np.ndarray, y_test: np.ndarray, thresholds: np.ndarray) -> pd.DataFrame:
    """
    Para cada umbral calcula métricas sobre la clase 1 (mal cliente).

    Returns
    -------
    DataFrame con métricas por umbral para el modelo dado
    """
    proba = model.predict_proba(X_test)[:, 1]
    rows  = []

    for t in thresholds:
        preds = (proba >= t).astype(int)
        rows.append({
            'Modelo':    name,
            'Umbral':    round(float(t), 4),
            'Recall':    round(recall_score(y_test, preds, zero_division=0), 4),
            'Precision': round(precision_score(y_test, preds, zero_division=0), 4),
            'F1':        round(f1_score(y_test, preds, zero_division=0), 4),
            'Accuracy':  round(accuracy_score(y_test, preds), 4),
            'ROC-AUC':   round(roc_auc_score(y_test, proba), 4),
        })

    return pd.DataFrame(rows)


# =============================================================================
# 5. ANÁLISIS DE COSTO — Pérdida por umbral
# =============================================================================

def plot_costo_umbral(models: List[Tuple[str, Any]], X_test: np.ndarray, y_test: np.ndarray, thresholds: Optional[np.ndarray] = None, cost_fp: int = 1, cost_fn: int = 5) -> pd.DataFrame:
    """
    Grafica pérdida total vs umbral de decisión para cada modelo.
    Pérdida = FP × cost_fp + FN × cost_fn

    Parameters
    ----------
    models     : lista de tuplas (nombre, modelo_entrenado)
    X_test     : features de test
    y_test     : etiqueta real (0=buen cliente, 1=mal cliente)
    thresholds : array de umbrales. Default: np.linspace(0.01, 0.99, 200)
    cost_fp    : costo de clasificar un buen cliente como malo  (default=1)
    cost_fn    : costo de clasificar un mal cliente como bueno  (default=5)

    Returns
    -------
    df_cost : DataFrame con [Modelo, Umbral, FP, FN, Perdida]
    """
    if thresholds is None:
        thresholds = np.linspace(0.01, 0.99, 200)

    colors = ['steelblue', 'darkorange', 'seagreen', 'crimson']
    rows   = []

    fig, ax = plt.subplots(figsize=(10, 5))

    for (name, model), color in zip(models, colors):
        proba  = model.predict_proba(X_test)[:, 1]
        losses = []

        for t in thresholds:
            preds = (proba >= t).astype(int)
            cm    = confusion_matrix(y_test, preds, labels=[0, 1])
            fp    = cm[0, 1]
            fn    = cm[1, 0]
            loss  = fp * cost_fp + fn * cost_fn

            losses.append(loss)
            rows.append({
                'Modelo':  name,
                'Umbral':  round(float(t), 4),
                'FP':      int(fp),
                'FN':      int(fn),
                'Perdida': int(loss),
            })

        losses     = np.array(losses)
        idx_optimo = np.argmin(losses)
        t_optimo   = thresholds[idx_optimo]

        ax.plot(thresholds, losses, label=name, color=color, linewidth=2)
        ax.axvline(x=t_optimo, color=color, linestyle='--', alpha=0.7,
                   label=f'{name} — t*={t_optimo:.2f}  (pérd.={losses[idx_optimo]:.0f})')
        ax.scatter([t_optimo], [losses[idx_optimo]], color=color, s=80, zorder=5)

    ax.set_xlabel('Umbral de decisión', fontsize=11)
    ax.set_ylabel(f'Pérdida  (FP×{cost_fp} + FN×{cost_fn})', fontsize=11)
    ax.set_title('Pérdida por Umbral de Decisión', fontweight='bold', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig('costo_umbral.png', dpi=150, bbox_inches='tight')
    plt.show()

    df_cost = pd.DataFrame(rows)

    df_optimal = (
        df_cost
        .loc[df_cost.groupby('Modelo')['Perdida'].idxmin()]
        .reset_index(drop=True)
        [['Modelo', 'Umbral', 'FP', 'FN', 'Perdida']]
    )
    print("\nUMBRAL ÓPTIMO POR COSTO (minimiza pérdida total)")
    print(f"   Función de pérdida: FP × {cost_fp}  +  FN × {cost_fn}")
    print(f"   FP = buenos → malos  |  FN = malos → buenos\n")
    print(df_optimal.to_string(index=False))

    return df_cost


# =============================================================================
# 6. VISUALIZACIONES
# =============================================================================

def plot_umbral_recall(df_thresholds: pd.DataFrame, models_names: List[str]) -> None:
    """Curva Recall / Precision / F1 vs umbral para cada modelo."""
    fig, axes = plt.subplots(1, len(models_names),
                             figsize=(5 * len(models_names), 4), sharey=True)
    if len(models_names) == 1:
        axes = [axes]

    for ax, nombre in zip(axes, models_names):
        sub = df_thresholds[df_thresholds['Modelo'] == nombre]
        ax.plot(sub['Umbral'], sub['Recall'],    marker='o', label='Recall',    color='crimson')
        ax.plot(sub['Umbral'], sub['Precision'], marker='s', label='Precision', color='steelblue')
        ax.plot(sub['Umbral'], sub['F1'],        marker='^', label='F1',        color='seagreen')

        optimo = sub.loc[sub['Recall'].idxmax()]
        ax.axvline(x=optimo['Umbral'], color='crimson', linestyle='--', alpha=0.5,
                   label=f"t óptimo={optimo['Umbral']:.2f}")

        ax.set_title(nombre, fontweight='bold', fontsize=9)
        ax.set_xlabel('Umbral de decisión')
        ax.set_ylim(0, 1.05)
        ax.legend(fontsize=8)
        ax.grid(alpha=0.3)

    axes[0].set_ylabel('Score')
    fig.suptitle('Recall / Precision / F1 por Umbral — Clase: Mal cliente',
                 fontweight='bold', fontsize=12)
    plt.tight_layout()
    plt.savefig('threshold_curves.png', dpi=150, bbox_inches='tight')
    plt.show()


def plot_roc_pr(final_models: List[Tuple[str, Any]], X_test: np.ndarray, y_test: np.ndarray) -> None:
    """Curvas ROC y Precision-Recall para todos los modelos."""
    fig, (ax_roc, ax_pr) = plt.subplots(1, 2, figsize=(13, 5))
    colors = ['steelblue', 'darkorange', 'seagreen', 'crimson']

    for (name, model), color in zip(final_models, colors):
        RocCurveDisplay.from_estimator(model, X_test, y_test,
                                       ax=ax_roc, name=name, color=color)
        PrecisionRecallDisplay.from_estimator(model, X_test, y_test,
                                              ax=ax_pr, name=name, color=color)

    ax_roc.set_title('Curva ROC', fontweight='bold')
    ax_roc.grid(alpha=0.3)
    ax_pr.set_title('Curva Precision-Recall\n(más informativa con clases desbalanceadas)',
                    fontweight='bold')
    ax_pr.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig('roc_pr_curves.png', dpi=150, bbox_inches='tight')
    plt.show()


def plot_confusion_matrices(final_models: List[Tuple[str, Any]], threshold: float, X_test: np.ndarray, y_test: np.ndarray) -> None:
    """Matriz de confusión para cada modelo con el umbral dado."""
    n = len(final_models)
    fig, axes = plt.subplots(1, n, figsize=(4 * n, 4))
    if n == 1:
        axes = [axes]

    for ax, (name, model) in zip(axes, final_models):
        proba = model.predict_proba(X_test)[:, 1]
        preds = (proba >= threshold).astype(int)
        cm    = confusion_matrix(y_test, preds)
        disp  = ConfusionMatrixDisplay(cm, display_labels=['Buen cliente', 'Mal cliente'])
        disp.plot(ax=ax, colorbar=False, cmap='Blues')
        ax.set_title(f'{name}\nUmbral={threshold:.4f}', fontweight='bold', fontsize=9)
        ax.grid(alpha=0)

    fig.suptitle('Matrices de Confusión — Umbral Seleccionado',
                 fontweight='bold', fontsize=12)
    plt.tight_layout()
    plt.savefig('confusion_matrices.png', dpi=150, bbox_inches='tight')
    plt.show()
