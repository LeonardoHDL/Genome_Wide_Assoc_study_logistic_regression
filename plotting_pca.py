import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#we'll beggin by reading the first argument, which will be the eigenvecs file

#It's to note that the name of the first column matches the values for the 
#1x1 values of eigenvecs, this is because in order to relate ID's from clinical file
#with eigenvecs file we must split the string because the format doesn't match
table=sys.argv[1]
print('data to be used as the file of eigenvectors:', sys.argv[1])

new_col_names=['UCHC_1-888-001_1-888-001', 'IID', 'PC1', 'PC2', 'PC3','PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'PC9', 'PC10']
eigenvecs=pd.read_table(table, names=new_col_names, sep=' ')
#below command is necessary to create a new ID column that mathces the one in clinical file
eigenvecs['IDnumber']= eigenvecs['UCHC_1-888-001_1-888-001'].str.split("_", expand = True)[1]
eigenvecs_final=eigenvecs.drop(['UCHC_1-888-001_1-888-001', 'IID'], axis=1)


#now that we already read our eigenvecs file, we now read the clinical file to identify the 
#inviduals origin in our plot and to check for population stratificaton
table2=sys.argv[2]
print('data to be used as clinical file:', sys.argv[2])
clinical_col_names=['Barcode', 'Plate', 'Position', 'IDnumber', 'Keloids', 'Sex',
       'Ethnicity', 'BirthYr', 'OnsetYr', 'AgeAtSample', 'AgeAtKeloid',
       'NumKeloids', 'LargestKeloid', 'WES']
clinical=pd.read_csv(table2,names=clinical_col_names)

#we now proceed to merge both files
finaldf=pd.merge(eigenvecs_final,clinical, how='inner')

#not that we have merged both dataframes, we are now interested on their ascendency, but due to big ammount
#of individuals coded as yoruba, we will recode as the toher tribes as 'not yoruba'

#comment if this is not a necessary step
finaldf['Ethnicity'] = finaldf['Ethnicity'].replace(['Ibo','Igbo', 'Edo','Idoma', 'Ebira','Fulami', 'Hausa', 'Ghanian', 'Bayelsa', 'Igbira', 'Aruguu',
                                          'Delta', 'nan', 'Uzaiba', 'Sobe', 'Ibibio', 'Urhos','Ebibio', 'Ibobio','Agbede',
                                          'Ijaw', 'Dadiya', 'Isekiri', 'Masa', 'Anan', 'Urobo', 'Igala',
                                          'Auchi', 'Kwale', 'Edo', 'Essan', 'Itsekiri', 'Esan', 'Izoko', 'nan', '    Yoruba',
                                                     'Edo ', 'Urohobo', 'Calasar'], 'Not Yoruba')


##now we will read the eigenvals file to also create a scree plot 
#which is useful to know how many PC's take into account for assoc studies
print('data to be used as eigenvals:', sys.argv[3])
table3=sys.argv[3]
eigenvals=pd.read_table(table3, names=['eigenvals'])


#this would be all the files that we need for plotting PCA

#We would now proceed with the first plot which will is a scree plot, next few lines 
#are just to make the file plottable
PC_component= [i+1 for i in range(len(eigenvals))]
eigenvals['decimals']=(eigenvals['eigenvals'] / eigenvals['eigenvals'].sum())


plt.plot(PC_component, eigenvals['decimals'], 'b-', linewidth=1)
plt.title('Scree Plot')
plt.xlabel(f'Principal Components')
plt.ylabel('Eigenvalue')
#I don't like the default legend so I typically make mine like below, e.g.
#with smaller fonts and a bit transparent so I do not cover up data, and make
#it moveable by the viewer in case upper-right is a bad place for it 
leg = plt.legend(['eigen values across PCs'], loc='best', borderpad=0.3, 
                 shadow=False, prop=plt.font_manager.FontProperties(size='large'),
                 markerscale=1)
leg.get_frame().set_alpha(0.4)
plt.xticks(range(1, 11, 1))

plt.show()

#now we we'll create the pca plot
#we haven't learn how to plot in a for loop so i will create manually 
#the six necessary plots

#it's necessary to create a new directory to save the imgs

#in order to place the imgs in the right folder we will need to add a fourth sys.arg

folder_where_imgs_will_be_saved=sys.argv[4]
print(f'directory where PCA plotts will be allocated: {folder_where_imgs_will_be_saved}')

#1.
plt.scatter(x=finaldf["PC1"], y=finaldf["PC2"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC1"], y=d["PC2"], label=pop)
plt.legend()
plt.xlabel(f'PC1')
plt.ylabel(f'PC2')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC1vsPC2.png')

#2.
plt.scatter(x=finaldf["PC1"], y=finaldf["PC3"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC1"], y=d["PC3"], label=pop)
plt.legend()
plt.xlabel(f'PC1')
plt.ylabel(f'PC3')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC1vsPC3.png')

#3.
plt.scatter(x=finaldf["PC1"], y=finaldf["PC4"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC1"], y=d["PC4"], label=pop)
plt.legend()
plt.xlabel(f'PC1')
plt.ylabel(f'PC4')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC1vsPC4.png')

#4.
plt.scatter(x=finaldf["PC2"], y=finaldf["PC3"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC2"], y=d["PC3"], label=pop)
plt.legend()
plt.xlabel(f'PC2')
plt.ylabel(f'PC3')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC2vsPC3.png')

#5.
plt.scatter(x=finaldf["PC2"], y=finaldf["PC4"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC2"], y=d["PC4"], label=pop)
plt.legend()
plt.xlabel(f'PC2')
plt.ylabel(f'PC4')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC2vsPC4.png')

#6.
plt.scatter(x=finaldf["PC3"], y=finaldf["PC4"], label="")
for pop in ['Yoruba', 'Not Yoruba' ]:
    d = finaldf[finaldf['Ethnicity'] == pop]
    plt.scatter(x=d["PC3"], y=d["PC4"], label=pop)
plt.legend()
plt.xlabel(f'PC3')
plt.ylabel(f'PC4')
plt.savefig(f'{folder_where_imgs_will_be_saved}PC3vsPC4.png')





