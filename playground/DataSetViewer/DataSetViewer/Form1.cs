using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Data.SQLite;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MySql.Data.MySqlClient;

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
        private IDictionary<string, DbConnection> _connections;

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            DbConnection sqlConn = new SqlConnection("data source=.;initial catalog=dbitest;user id=sa;password=Password123");
            DbConnection mysqlConn = new MySqlConnection("Server=localhost;Database=dbitest;Uid=root;Pwd=;");
            DbConnection sqliteConn = new SQLiteConnection("data source=dbitest");
            _connections = new Dictionary<string, DbConnection>
                               {
                                   { "MS SQL", sqlConn },
                                   { "MySql", mysqlConn },
                                   { "SQLite", sqliteConn }
                               };

            var lst = new List<string> {"MS SQL", "MySql", "SQLite"};
            cbProviders.DataSource = lst;
           
        }

        private void cbTable_SelectedIndexChanged(object sender, EventArgs e)
        {
            dgSchema.DataSource = _schema.Tables[cbTable.SelectedIndex];
        }

        private void BindGrid(DbConnection conn)
        {
                conn.Open();
                _schema = new DataSet();
                var schema = conn.GetSchema();

                foreach (DataRow dataRow in schema.Rows)
                {
                    var tableName = dataRow["CollectionName"].ToString();
                    if(!_schema.Tables.Contains(tableName))
                    {
                        var dt = conn.GetSchema(tableName);
                        dt.TableName = tableName;
                        _schema.Tables.Add(dt);
                    }
                }
                conn.Close();
                dgSchema.DataSource = _schema.Tables[0];

                cbTable.DataSource = _schema.Tables[0];
                cbTable.DisplayMember = "CollectionName";
                cbTable.ValueMember = "CollectionName";
                _previousWidth = dgSchema.Width;
                _previousState = WindowState;
        }

        private void ResizeGrid(DataGridView dataGrid, ref int prevWidth)
        {
            
            dataGrid.Width = Width - (SystemInformation.VerticalScrollBarWidth + 10);
            if (prevWidth == 0)
                prevWidth = dataGrid.Width;
            if (prevWidth == dataGrid.Width)
                return;

            int fixedWidth = SystemInformation.VerticalScrollBarWidth +
               dataGrid.RowHeadersWidth - 10;
            
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

        private void cbProviders_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid(_connections[cbProviders.SelectedItem.ToString()]);
        }
    }
}
