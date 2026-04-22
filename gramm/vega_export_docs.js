const EXAMPLES = [
  { id: 'test_geom_point', title: 'Basic Scatter Plot', matlabFile: 'geom_point_1.m' },
  { id: 'test_geom_point_colors', title: 'Scatter Plot with Color Groups', matlabFile: 'geom_point_2.m' },
  { id: 'test_geom_line', title: 'Basic Line Chart', matlabFile: 'geom_line_1.m' },
  { id: 'test_geom_line_multi', title: 'Multi-Series Line Chart', matlabFile: 'geom_line_2.m' },
  { id: 'test_geom_bar_categorical', title: 'Categorical Bar Chart', matlabFile: 'geom_bar_1.m' },
  { id: 'test_geom_bar_groups', title: 'Grouped Bar Chart', matlabFile: 'geom_bar_2.m' },
  { id: 'test_geom_jitter', title: 'Jittered Points', matlabFile: 'geom_jitter_1.m' },
  { id: 'test_geom_raster', title: 'Strip Plot (Raster)', matlabFile: 'geom_raster_1.m' },
  { id: 'test_combined_point_line', title: 'Combined Point and Line', matlabFile: 'geom_point_line_1.m' },
  { id: 'test_nan_handling', title: 'Data with NaN Values', matlabFile: 'geom_point_line_2.m' },
  { id: 'test_custom_params', title: 'Custom Export Parameters', matlabFile: 'geom_line_3.m' },
  { id: 'test_geom_swarm', title: 'Beeswarm Plot', matlabFile: 'geom_swarm_1.m' },
  { id: 'test_interactive_scatter', title: 'Interactive Scatter Plot', matlabFile: 'geom_point_3.m' },
  { id: 'test_interactive_lines', title: 'Interactive Multi-Series Lines', matlabFile: 'geom_line_4.m' },
  { id: 'test_interactive_bars', title: 'Interactive Grouped Bars', matlabFile: 'geom_bar_3.m' },
  { id: 'test_interactive_jitter', title: 'Interactive Jitter Plot', matlabFile: 'geom_jitter_2.m' },
  { id: 'test_standard_legend', title: 'Standard Legend (Non-Interactive)', matlabFile: 'geom_point_4.m' },
  { id: 'test_interactive_legend', title: 'Interactive Legend Demo', matlabFile: 'geom_point_5.m' },
  { id: 'test_large_interactive', title: 'Large Dataset Interactive Test', matlabFile: 'geom_point_6.m' },
  { id: 'test_stat_glm', title: 'Linear Regression (GLM)', matlabFile: 'stat_glm_1.m' },
  { id: 'test_stat_glm_groups', title: 'Multi-Group GLM', matlabFile: 'stat_glm_2.m' },
  { id: 'test_stat_smooth', title: 'Eilers Smoothing', matlabFile: 'stat_smooth_1.m' },
  { id: 'test_stat_bin', title: 'Basic Histogram', matlabFile: 'stat_bin_1.m' },
  { id: 'test_stat_bin_groups', title: 'Grouped Histogram', matlabFile: 'stat_bin_2.m' },
  { id: 'test_stat_summary', title: 'Statistical Summary', matlabFile: 'stat_summary_1.m' },
  { id: 'test_stat_density', title: 'Kernel Density', matlabFile: 'stat_density_1.m' },
  { id: 'test_stat_violin', title: 'Violin Plots', matlabFile: 'stat_violin_1.m' },
  { id: 'test_stat_boxplot', title: 'Box Plots', matlabFile: 'stat_boxplot_1.m' },
  { id: 'test_stat_qq', title: 'Q-Q Plots', matlabFile: 'stat_qq_1.m' },
  { id: 'test_stat_fit', title: 'Polynomial Fitting', matlabFile: 'stat_fit_1.m' },
  { id: 'test_stat_bin2d', title: '2D Histograms', matlabFile: 'stat_bin2d_1.m' },
  { id: 'test_stat_ellipse', title: 'Confidence Ellipses', matlabFile: 'stat_ellipse_1.m' }
];

const gallery = document.getElementById('examples-gallery');
const outline = document.getElementById('example-outline');

function createPanel(label) {
  const panel = document.createElement('div');
  panel.className = 'panel';

  const panelLabel = document.createElement('div');
  panelLabel.className = 'panel-label';
  panelLabel.textContent = label;
  panel.appendChild(panelLabel);

  return panel;
}

async function fetchText(path) {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`Failed to load file: ${path}`);
  }
  return response.text();
}

async function embedVegaFromJson(container, jsonPath) {
  const response = await fetch(jsonPath);
  if (!response.ok) {
    throw new Error(`Failed to load Vega spec: ${jsonPath}`);
  }

  const spec = await response.json();
  return vegaEmbed(container, spec, {
    actions: false,
    renderer: 'canvas'
  });
}

function createErrorBox(message) {
  const errorBox = document.createElement('pre');
  errorBox.className = 'error-box';
  errorBox.textContent = message;
  return errorBox;
}

function renderExample(example, index) {
  const article = document.createElement('article');
  article.className = 'example-card';
  article.id = `example-${example.id}`;

  const title = document.createElement('h3');
  title.className = 'example-title';
  title.textContent = `${index + 1}. ${example.title}`;
  article.appendChild(title);

  const scriptPath = `./test/script/${example.matlabFile}`;
  const svgPath = `./test/gramm_svg/${example.id}.svg`;
  const vegaJsonPath = `./test/gramm_vega/${example.id}.json`;

  const grid = document.createElement('div');
  grid.className = 'example-grid';

  const codePanel = createPanel(`MATLAB Code (${example.matlabFile})`);
  const codeBlock = document.createElement('pre');
  codeBlock.className = 'code-block';
  codeBlock.textContent = 'Loading script...';
  codePanel.appendChild(codeBlock);
  grid.appendChild(codePanel);

  const outputsGrid = document.createElement('div');
  outputsGrid.className = 'output-grid';

  const svgPanel = createPanel('Gramm SVG Output');
  const svgImage = document.createElement('img');
  svgImage.className = 'svg-image';
  svgImage.src = svgPath;
  svgImage.alt = `${example.title} SVG`;
  svgImage.loading = 'lazy';
  svgPanel.appendChild(svgImage);

  const vegaPanel = createPanel('Vega Output');
  const vegaHost = document.createElement('div');
  vegaHost.className = 'vega-host';
  vegaPanel.appendChild(vegaHost);

  outputsGrid.appendChild(svgPanel);
  outputsGrid.appendChild(vegaPanel);
  grid.appendChild(outputsGrid);
  article.appendChild(grid);

  fetchText(scriptPath)
    .then((code) => {
      codeBlock.textContent = code.trim();
    })
    .catch((error) => {
      codeBlock.replaceWith(createErrorBox(error.message));
    });

  embedVegaFromJson(vegaHost, vegaJsonPath)
    .catch((error) => {
      vegaHost.replaceWith(createErrorBox(error.message));
    });

  return article;
}

function renderOutlineLink(example, index) {
  const link = document.createElement('a');
  link.className = 'outline-link outline-link-example';
  link.href = `#example-${example.id}`;
  link.textContent = `${index + 1}. ${example.title}`;
  return link;
}

function renderAllExamples() {
  EXAMPLES.forEach((example, index) => {
    outline.appendChild(renderOutlineLink(example, index));
    gallery.appendChild(renderExample(example, index));
  });
}

renderAllExamples();
