from typing import Tuple, List, Optional, Union

from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, StandardScaler
from sklearn.decomposition import PCA


SEED = 121

ATTRIBUTE_NAMES = {
    'Attribute1': 'checking_status',
    'Attribute2': 'duration_months',
    'Attribute3': 'credit_history',
    'Attribute4': 'purpose',
    'Attribute5': 'credit_amount',
    'Attribute6': 'savings_status',
    'Attribute7': 'employment_duration',
    'Attribute8': 'installment_rate',
    'Attribute9': 'personal_status_sex',
    'Attribute10': 'other_debtors',
    'Attribute11': 'present_residence_since',
    'Attribute12': 'property',
    'Attribute13': 'age_years',
    'Attribute14': 'other_installment_plans',
    'Attribute15': 'housing',
    'Attribute16': 'existing_credits',
    'Attribute17': 'job',
    'Attribute18': 'dependents',
    'Attribute19': 'telephone',
    'Attribute20': 'foreign_worker'
}


num_attributes = ['Attribute2', 'Attribute5', 'Attribute8',
            'Attribute11', 'Attribute13', 'Attribute16']

ordinal_attributes = ['Attribute1', 'Attribute6', 'Attribute7', 'Attribute17']

onehot_attributes = [
    'Attribute3', 'Attribute4', 'Attribute9', 'Attribute10',
    'Attribute12', 'Attribute14', 'Attribute15', 'Attribute19', 'Attribute20'
]

ordinal_categories = [
    ['A14', 'A11', 'A12', 'A13'],           # Estatus cuenta
    ['A65', 'A61', 'A62', 'A63', 'A64'],    # Ahorros
    ['A71', 'A72', 'A73', 'A74', 'A75'],    # Empleo
    ['A171', 'A172', 'A173', 'A174'],       # Tipo de trabajo
]

def build_num_preprocessor(num_attributes: List[str]) -> Tuple[str, Pipeline, List[str]]:
    """Imputa con mediana y escala variables numéricas."""
    num_pipe = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler',  StandardScaler()),
    ])
    return ('num', num_pipe, num_attributes)


def build_cat_preprocessor(
    ordinal_attributes: List[str],
    ordinal_categories: Union[List[List[str]], str] = 'auto',
    onehot_attributes: Optional[List[str]] = None) -> List[Tuple[str, Pipeline, List[str]]]:
    """Construye transformadores ordinales y one-hot para variables categóricas."""
    transformers = []

    ordinal_pipe = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('ordinal', OrdinalEncoder(
            categories=ordinal_categories,
            handle_unknown='use_encoded_value',
            unknown_value=-1,
        )),
    ])

    if onehot_attributes:
        onehot_pipe = Pipeline(steps=[
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('onehot',  OneHotEncoder(handle_unknown='ignore')),
        ])
        transformers.append(('onehot', onehot_pipe, onehot_attributes))

    transformers.append(('ordinal', ordinal_pipe, ordinal_attributes))
    return transformers