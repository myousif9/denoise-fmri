rule aroma_nonaggr:
    input: 
        nii = bids(root='results',datatype='func',desc='smoothed',fwhm='{fwhm}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
        mixing = config['input_path']['mixing'],
        noiseICs = config['input_path']['noiseICs'],
        mask_nii = config['input_path']['preproc_mask']
    params:
        container = config['singularity']['fsl']
    output: 
        nii = bids(root='results',datatype='func',desc='AROMAnonaggr',fwhm='{fwhm}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
    container: config['singularity']['fsl']
    group: 'subj'
    shell:
        'fsl_regfilt -i {input.nii} -f `cat {input.noiseICs}` -d {input.mixing} -o {output.nii} -m {input.mask_nii}' 

#this regresses out confounds after aroma 
rule aroma_aggr:
    input: 
        nii = bids(root='results',datatype='func',desc='AROMAnonaggr',fwhm='{fwhm}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
        json = bids(root='results',datatype='func',desc='smoothed',fwhm='{fwhm}',suffix='bold.json',**config['input_wildcards']['preproc_bold']),
        confounds_tsv = config['input_path']['confounds'],
        mask_nii = config['input_path']['preproc_mask']
    params:
        confounds_to_use = lambda wildcards: config['confounds'][int(wildcards.confounds_idx)-1]['regressors'],
        confounds_name = lambda wildcards: config['confounds'][int(wildcards.confounds_idx)-1]['name'],
        standardize = True,
        detrend = True,
        low_pass = False,
        high_pass = False,
    output: 
        nii = bids(root='results',datatype='func',desc='AROMAdenoised',fwhm='{fwhm}',confounds='{confounds_idx}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
        json= bids(root='results',datatype='func',desc='AROMAdenoised',fwhm='{fwhm}',confounds='{confounds_idx}',suffix='bold.json',**config['input_wildcards']['preproc_bold'])
    group: 'subj'
    script: '../scripts/denoise.py'

    
