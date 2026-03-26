# =============================================================================
# eda_utils.py
# Utilidades para Análisis Exploratorio de Datos — German Credit Data
# =============================================================================

from .configs import ATTRIBUTE_NAMES
from typing import Dict, Any, List
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# =============================================================================
# 1. CONFIGURACIÓN DE ESTILOS DE GRÁFICOS
# =============================================================================

def setup_plot_style() -> None:
    """
    Configura los estilos globales de matplotlib y seaborn para visualizaciones
    consistentes en todo el análisis.
    
    Establece:
      - Estilo seaborn: whitegrid
      - Contexto: notebook
      - Paleta: viridis
      - Tamaño figuras: (12, 6)
      - Tamaño fuente: 10
    """
    sns.set_style('whitegrid')
    sns.set_context('notebook')
    sns.set_palette("viridis")
    plt.rcParams['figure.figsize'] = (12, 6)
    plt.rcParams['font.size'] = 10

# =============================================================================
# 2. ANÁLISIS DE VARIABLES NUMÉRICAS
# =============================================================================

def analyze_numerical(df: pd.DataFrame, num_attributes: List[str], target_col:str) -> None: 
    """
        Analiza las estadísticas descriptivas de los atributos numéricos y la distribución
        de estas con la varible objetivo usando visualizaciones comparativas.
    """    
    for col in num_attributes:
        col = ATTRIBUTE_NAMES[col]
        print(f"\n{col.upper()}:")
        print(df.groupby('class')[col].describe().drop(columns=['count']).round(2))
        print("-"*80)

    # ------------ Visualización de distribuciones -------------------
    fig, axes = plt.subplots(2, 4, figsize=(20, 10))
    axes = axes.ravel()

    for idx, col in enumerate(num_attributes):
        if idx < 9:
            col = ATTRIBUTE_NAMES[col]
            data_good = df[df['class'] == 'Good'][col]
            data_bad = df[df['class'] == 'Bad'][col]

            bp = axes[idx].boxplot([data_good, data_bad], tick_labels = ['Good', 'Bad'],
                                patch_artist=True)
            bp['boxes'][0].set_facecolor('lightgreen')
            bp['boxes'][1].set_facecolor('lightcoral')
            axes[idx].set_title(f'{col.replace("_", " ").title()}', fontweight='bold')
            axes[idx].set_ylabel('Valor')

    plt.suptitle('Distribución de Variables Numéricas por Clase', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.show()


# =============================================================================
# 2. ANÁLISIS DE VARIABLES CATEGÓRICAS
# =============================================================================

def analyze_categorical(df: pd.DataFrame, cat_col: str, target_col: str) -> None:
    """
    Analiza la relación entre una variable categórica y la variable objetivo
    mediante tablas de contingencia y visualizaciones comparativas.
    
    Genera dos gráficos horizontales:
      - Izquierdo: distribución absoluta (stacked bar chart)
      - Derecho: proporción por categoría (grouped bar chart con %)
    
    """
    # Crear tabla de contingencia
    contingency: pd.DataFrame = pd.crosstab(df[cat_col], df[target_col], normalize='index') * 100
    
    # Renombrar columnas para claridad (asumiendo clases binarias)
    if contingency.shape[1] == 2:
        contingency.columns = ['Bad (%)', 'Good (%)']
    
    # Crear figura con subplots
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Panel izquierdo: distribución absoluta
    cat_counts: pd.DataFrame = pd.crosstab(df[cat_col], df[target_col])
    cat_counts.plot(
        kind='bar',
        stacked=True,
        ax=axes[0],
        color=['lightcoral', 'lightgreen'],
        legend=False
    )
    axes[0].set_title(
        f'{cat_col.replace("_", " ").title()}\n(Distribución absoluta)',
        fontweight='bold'
    )
    axes[0].set_xlabel('Categoría')
    axes[0].set_ylabel('Cantidad')
    axes[0].tick_params(axis='x', rotation=45)
    
    # Panel derecho: proporción por categoría
    contingency.plot(
        kind='bar',
        ax=axes[1],
        color=['lightcoral', 'lightgreen'],
    )
    axes[1].set_title(
        f'{cat_col.replace("_", " ").title()}\n(Proporción por categoría)',
        fontweight='bold'
    )
    axes[1].set_xlabel('Categoría')
    axes[1].set_ylabel('Porcentaje (%)')
    axes[1].tick_params(axis='x', rotation=45)
    axes[1].legend(title='Clase real')
    
    plt.tight_layout()
    plt.show()
    