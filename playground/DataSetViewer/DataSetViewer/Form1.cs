using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace DataSetViewer
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private DataSet _schema;
        private int _previousWidth;
        private FormWindowState _previousState;

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            DbConnection conn = new SqlConnection("data source=.\\SQLExpress;initial catalog=dbitest;user id=sa;password=Password123");
            conn.Open();
            _schema = new DataSet();
            var schema = conn.GetSchema();

            foreach (DataRow dataRow in schema.Rows)
            {
                _schema.Tables.Add(conn.GetSchema(dataRow["CollectionName"].ToString()));
            }
            
            dgSchema.DataSource = _schema.Tables[0];
            
            cbTable.DataSource = _schema.Tables[0];
            cbTable.DisplayMember = "CollectionName";
            cbTable.ValueMember = "CollectionName";
            _previousWidth = dgSchema.Width;
            _previousState = WindowState;
        }

        private void cbTable_SelectedIndexChanged(object sender, EventArgs e)
        {
            dgSchema.DataSource = _schema.Tables[cbTable.SelectedIndex];
        }

        private void ResizeGrid(DataGridView dataGrid, ref int prevWidth)
        {
            
            var dff = Width - (_previousWidth - 2);
            dataGrid.Width = dataGrid.Width + dff;
            if (prevWidth == 0)
                prevWidth = dataGrid.Width;
            if (prevWidth == dataGrid.Width)
                return;

            int fixedWidth = SystemInformation.VerticalScrollBarWidth +
               dataGrid.RowHeadersWidth + 2;
            
            int mul = 100 * (dataGrid.Width - fixedWidth) /
               (prevWidth - fixedWidth);
            int columnWidth;
            int total = 0;
            DataGridViewColumn lastVisibleCol = null;

            for (int i = 0; i < dataGrid.ColumnCount; i++)
                if (dataGrid.Columns[i].Visible)
                {
                    columnWidth = (dataGrid.Columns[i].Width * mul + 50) / 100;
                    dataGrid.Columns[i].Width =
                       Math.Max(columnWidth, dataGrid.Columns[i].MinimumWidth);
                    total += dataGrid.Columns[i].Width;
                    lastVisibleCol = dataGrid.Columns[i];
                }
            if (lastVisibleCol == null)
                return;
            columnWidth = dataGrid.Width - total +
               lastVisibleCol.Width - fixedWidth;
            lastVisibleCol.Width =
               Math.Max(columnWidth, lastVisibleCol.MinimumWidth);
            prevWidth = dataGrid.Width;
        }

        private void Form1_Resize(object sender, EventArgs e)
        {
            if (WindowState != _previousState && WindowState !=
             FormWindowState.Minimized)
            {
                _previousState = WindowState;
                ResizeGrid(dgSchema, ref _previousWidth);
            }
        }

        private void Form1_ResizeEnd(object sender, EventArgs e)
        {
            ResizeGrid(dgSchema, ref _previousWidth);
            
        }
    }
}
