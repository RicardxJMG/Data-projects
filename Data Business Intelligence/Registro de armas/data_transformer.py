'''
Autor: Ricardo Martínez
Datos: Los datos fuero obtenidos de la página https://historico.datos.gob.mx/busca/dataset/armas-registradas-por-diferentes-motivos/resource/7f864d5b-eab2-4732-98b1-dd3b4c4eaf81,
       los cuales son de libre uso. Estos datos siguen activos y fueron descargados el 31 de mayo de 2025.

El script  transforma los datos que están en formato .xlsx, que están multi-indexados en un formato ancho, a un archivo .csv que está en formato largo.
'''


import pandas as pd

def pipeline(quarter,  year='2024'):

  name = 'modalidadesarmas_'+ quarter +'_trimestre_'+year+'.xlsx'

  try:
    df = pd.read_excel(name, header=[0,1], skipfooter=2)
  except:
    print('--- No ha sido posible leer la tabla ---')
    return pd.DataFrame()


  df.drop(columns = df.columns[-1], inplace=True)

  df.columns = pd.MultiIndex.from_tuples([(c[0].lower().replace(' ', "_").replace("\n",'_'),
                                          c[1].lower()) for c in df.columns])

  df.columns = ["{} {}".format(level_0, level_1) if level_1!=level_0 else
                level_0.strip() for level_0, level_1 in df.columns]

  # fix possible error for those columns which has 'militar' in their name
  col_list = df.columns.to_list()
  fix_militar = [col for col in col_list if 'militar' in col]

  df.rename(columns={
      fix_militar[0]: 'personal_militar_en_activo largas',
      fix_militar[1]: 'personal_militar_en_activo cortas'
  }, inplace=True)

  df['trimestre'] = quarter

  df_long = pd.melt(df, id_vars=['estado', 'trimestre'], value_vars = df.columns[1:-1], value_name='total')
  df_long[['motivo_de_uso', 'tipo_de_arma']] =  df_long['variable'].str.split(' ',expand = True)
  df_long.drop(columns='variable', inplace=True)
  df_long['year'] = year
  df_long['estado'] = df_long['estado'].str.lower()

  return df_long





if __name__ == '__main__':

  year = '2024'  # modficar al agregar más datos sobre años anteriores
  quarter = ['1er', '2do', '3er', '4to']

  for q in quarter:
    df = pipeline(q)
    name = 'modalidad_armas_'+ q +'_trimestre_'+year+'_long.csv'
    df.to_csv(name, index=False)