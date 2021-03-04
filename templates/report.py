#!/usr/bin/env python3

import ast
import pandas as pd
import plotly.graph_objs as go
from plotly.offline import plot
from plotly.subplots import make_subplots

GRAPH_FIG = "$graph_fig"
VCF = "$vcf"

colorscale = ['#f0f0f0', '#5a6e92','#04a0fc']

def convert_tuple(tup):
    try:
        tup = ast.literal_eval(tup)
        str =  ', '.join(tup) 
        return str
    except:
        return tup

def df_to_plotly(df):
    return {'z': df.values.tolist(),
            'x': df.columns.tolist(),
            'y': df.index.tolist()}
    
def main(graph_ref_fig, vcf):

    # load data files

    # main report skeleton 
    fig = make_subplots(rows=11, cols=2, vertical_spacing=0.1, 
                    specs=[[None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None],
                           [None, None]],
                        subplot_titles=("","", "", ""))

    # intro text
    summary = ('vg-nf integrates <a href="https://github.com/vgteam/vg"> the vg</a> toolkit<br>'
               'build of a variation graph from a reference FASTA file and call variants.<br> '
               ' <br>'
               'A total of {0} samples were analysed with a variantion graph composed of {1} sequences.'
               ' <br>'.format(1000, 10000))

    fig.add_annotation(x=0, xref='paper', y=1, yref='paper', text=summary,
                       showarrow=False, font=dict(size=14), align='left', 
                       bgcolor='#f0f0f0')

    # Graph Reference
    fig.add_annotation(x=0, xref='paper', y=0.95, yref='paper', text="Variation Graph Reference",
                       showarrow=False, font=dict(size=14, color='#04a0fc'), align='left')
    
    img_width = 1600
    img_height = 900
    # not sure if this works
    fig.add_layout_image(
            sizex=img_width,
            sizey=img_height,
            xref="x",
            yref="y",
            opacity=1.0,
            layer="below",
            source=graph_ref_fig
            row=1, col=1)
    
    # title
    fig.update_layout(title={'text': "<b>sv-nf Report</b>",
                            'y':0.95,
                            'x':0.5,
                            'xanchor': 'center',
                            'yanchor': 'top',
                            'font': {'size': 24, 'color': '#04a0fc'}})
    fig.update_layout(height=1080, template='ggplot2', plot_bgcolor='rgba(0,0,0,0)')
    fig.write_html("multiqc_report.html", include_plotlyjs="cdn")
    

if __name__ == "__main__":
    main(GRAPH_FIG, VCF)

