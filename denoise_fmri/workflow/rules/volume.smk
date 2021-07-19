rule smooth:
    input:
        nii = config['input_path']['preproc_bold'],
        json = re.sub('.nii.gz','.json',config['input_path']['preproc_bold'])
    params:
        fwhm = lambda wildcards: float(wildcards.fwhm)
    output:
        nii = bids(root='results',datatype='func',desc='smoothed',fwhm='{fwhm}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
        json = bids(root='results',datatype='func',desc='smoothed',fwhm='{fwhm}',suffix='bold.json',**config['input_wildcards']['preproc_bold'])
    group: 'subj'
    script: '../scripts/smooth.py'

rule denoise:
    input: 
        nii = bids(root='results',datatype='func',desc='smoothed',fwhm='{fwhm}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
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
        nii = bids(root='results',datatype='func',desc='denoised',fwhm='{fwhm}',confounds='{confounds_idx}',suffix='bold.nii.gz',**config['input_wildcards']['preproc_bold']),
        json= bids(root='results',datatype='func',desc='denoised',fwhm='{fwhm}',confounds='{confounds_idx}',suffix='bold.json',**config['input_wildcards']['preproc_bold'])
    group: 'subj'
    script: '../scripts/denoise.py'